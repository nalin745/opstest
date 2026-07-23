output "service_name" {
  description = "Name of the ECS service."
  value       = aws_ecs_service.application.name
}

output "service_id" {
  description = "Terraform ID of the ECS service."
  value       = aws_ecs_service.application.id
}

output "service_cluster" {
  description = "ECS cluster used by the service."
  value       = aws_ecs_service.application.cluster
}

output "task_definition_arn" {
  description = "ARN of the ECS task definition revision."
  value       = aws_ecs_task_definition.application.arn
}

output "task_definition_family" {
  description = "Family of the ECS task definition."
  value       = aws_ecs_task_definition.application.family
}

output "task_execution_role_arn" {
  description = "ARN of the ECS task execution role."
  value       = aws_iam_role.execution.arn
}

output "task_role_arn" {
  description = "ARN of the application task role."
  value       = aws_iam_role.task.arn
}

output "application_log_group_name" {
  description = "CloudWatch application log-group name."
  value       = aws_cloudwatch_log_group.application.name
}

output "application_log_group_arn" {
  description = "CloudWatch application log-group ARN."
  value       = aws_cloudwatch_log_group.application.arn
}

output "autoscaling_resource_id" {
  description = "Application Auto Scaling resource identifier."
  value       = aws_appautoscaling_target.ecs_service.resource_id
}

output "service_arn" {
  description = "ARN of the ECS service."
  value       = aws_ecs_service.application.id
}