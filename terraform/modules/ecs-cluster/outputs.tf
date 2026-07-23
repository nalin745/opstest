output "cluster_id" {
  description = "ID of the ECS cluster."
  value       = aws_ecs_cluster.main.id
}

output "cluster_arn" {
  description = "ARN of the ECS cluster."
  value       = aws_ecs_cluster.main.arn
}

output "cluster_name" {
  description = "Name of the ECS cluster."
  value       = aws_ecs_cluster.main.name
}

output "execute_command_log_group_name" {
  description = "CloudWatch Log Group used by ECS Exec."
  value       = try(aws_cloudwatch_log_group.ecs_exec[0].name, null)
}
