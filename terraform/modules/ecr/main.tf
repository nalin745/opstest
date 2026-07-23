locals {
  repository_full_name = "${var.project_name}/${var.environment}/${var.repository_name}"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.common_tags
  )
}

resource "aws_ecr_repository" "main" {
  name = local.repository_full_name

  image_tag_mutability = var.image_tag_mutability

  force_delete = var.force_delete

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(
    local.common_tags,
    {
      Name = local.repository_full_name
    }
  )
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Remove old untagged images"

        selection = {
          tagStatus   = "untagged"
          countType   = "imageCountMoreThan"
          countNumber = var.untagged_image_retention_count
        }

        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Retain a controlled number of release images"

        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["release-", "v"]
          countType     = "imageCountMoreThan"
          countNumber   = var.release_image_retention_count
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}
