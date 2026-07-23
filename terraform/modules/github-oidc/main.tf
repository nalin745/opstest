locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.common_tags
  )

  github_subject = (
    "repo:${var.github_owner}/${var.github_repository}:environment:${var.github_environment_name}"
  )
}

# ---------------------------------------------------------
# GitHub OIDC provider
#
# Only create this when the AWS account does not already have
# token.actions.githubusercontent.com configured.
# ---------------------------------------------------------

resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 1 : 0

  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  # AWS no longer requires manual GitHub certificate rotation in normal use,
  # but the Terraform resource schema still expects a thumbprint list.
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-github-oidc"
    }
  )
}

locals {
  oidc_provider_arn = (
    var.create_oidc_provider
    ? aws_iam_openid_connect_provider.github[0].arn
    : var.existing_oidc_provider_arn
  )
}

# ---------------------------------------------------------
# GitHub OIDC trust policy
# ---------------------------------------------------------

data "aws_iam_policy_document" "github_trust" {
  statement {
    sid    = "AllowGitHubActionsOIDC"
    effect = "Allow"

    principals {
      type = "Federated"

      identifiers = [
        local.oidc_provider_arn
      ]
    }

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        local.github_subject
      ]
    }
  }
}

resource "aws_iam_role" "github_deploy" {
  name = "${local.name_prefix}-github-deploy-role"

  assume_role_policy = data.aws_iam_policy_document.github_trust.json

  description = (
    "Deployment role assumed by GitHub Actions using OIDC."
  )

  max_session_duration = 3600

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-github-deploy-role"
    }
  )
}

# ---------------------------------------------------------
# Least-privilege GitHub deployment policy
# ---------------------------------------------------------

data "aws_iam_policy_document" "github_deploy" {
  statement {
    sid    = "AuthenticateToECR"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "PushApplicationImages"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]

    resources = [
      var.ecr_repository_arn
    ]
  }

  statement {
    sid    = "ReadECSDeploymentInformation"
    effect = "Allow"

    actions = [
      "ecs:DescribeClusters",
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeTasks",
      "ecs:ListTasks"
    ]

    resources = ["*"]
  }

  # RegisterTaskDefinition does not support restricting the Resource field
  # to one task-definition family, so the permission uses "*".
  #
  # Risk is reduced by:
  # - restricting iam:PassRole
  # - restricting ecs:UpdateService
  # - restricting the OIDC repository/environment trust
  statement {
    sid    = "RegisterTaskDefinitionRevision"
    effect = "Allow"

    actions = [
      "ecs:RegisterTaskDefinition"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "TagApplicationTaskDefinitions"
    effect = "Allow"

    actions = [
      "ecs:TagResource"
    ]

    resources = [
      "arn:aws:ecs:${var.aws_region}:${var.aws_account_id}:task-definition/${var.task_definition_family}:*"
    ]
  }

  statement {
    sid    = "UpdateOnlyApplicationService"
    effect = "Allow"

    actions = [
      "ecs:UpdateService"
    ]

    resources = [
      var.ecs_service_arn
    ]

    condition {
      test     = "ArnEquals"
      variable = "ecs:cluster"

      values = [
        var.ecs_cluster_arn
      ]
    }
  }

  statement {
    sid    = "PassOnlyApprovedECSTaskRoles"
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = [
      var.task_execution_role_arn,
      var.task_role_arn
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"

      values = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy" "github_deploy" {
  name = "${local.name_prefix}-github-deploy-policy"
  role = aws_iam_role.github_deploy.id

  policy = data.aws_iam_policy_document.github_deploy.json
}

# ---------------------------------------------------------
# Input checks
# ---------------------------------------------------------

check "existing_provider_configuration" {
  assert {
    condition = (
      var.create_oidc_provider ||
      var.existing_oidc_provider_arn != null
    )

    error_message = "existing_oidc_provider_arn is required when create_oidc_provider is false."
  }
}

check "github_identity_values" {
  assert {
    condition = (
      length(trimspace(var.github_owner)) > 0 &&
      length(trimspace(var.github_repository)) > 0 &&
      length(trimspace(var.github_environment_name)) > 0
    )

    error_message = "GitHub owner, repository and environment must not be empty."
  }
}
