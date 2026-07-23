output "alb_security_group_id" {
  description = "Security group attached to the Application Load Balancer."
  value       = aws_security_group.alb.id
}

output "ecs_tasks_security_group_id" {
  description = "Security group attached to ECS Fargate tasks."
  value       = aws_security_group.ecs_tasks.id
}

output "database_security_group_id" {
  description = "Security group attached to the relational database."
  value       = try(aws_security_group.database[0].id, null)
}

output "redis_security_group_id" {
  description = "Security group attached to Redis."
  value       = try(aws_security_group.redis[0].id, null)
}
