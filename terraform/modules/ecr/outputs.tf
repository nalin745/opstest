output "repository_name" {
  description = "Name of the ECR repository."
  value       = aws_ecr_repository.main.name
}

output "repository_url" {
  description = "URL used when tagging and pushing container images."
  value       = aws_ecr_repository.main.repository_url
}

output "repository_arn" {
  description = "ARN of the ECR repository."
  value       = aws_ecr_repository.main.arn
}

output "registry_id" {
  description = "AWS registry ID containing the repository."
  value       = aws_ecr_repository.main.registry_id
}
