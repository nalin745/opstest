output "github_deploy_role_arn" {
  description = "IAM role ARN assumed by GitHub Actions."
  value       = aws_iam_role.github_deploy.arn
}

output "github_deploy_role_name" {
  description = "IAM deployment role name."
  value       = aws_iam_role.github_deploy.name
}

output "github_oidc_provider_arn" {
  description = "GitHub OIDC provider ARN."
  value       = local.oidc_provider_arn
}

output "github_oidc_subject" {
  description = "GitHub OIDC subject permitted to assume the role."
  value       = local.github_subject
}
