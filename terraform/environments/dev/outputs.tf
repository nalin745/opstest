output "vpc_id" {
  description = "ID of the development VPC."
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "Development public subnet IDs."
  value       = module.networking.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "Development private application subnet IDs."
  value       = module.networking.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "Development private database subnet IDs."
  value       = module.networking.private_db_subnet_ids
}

output "db_subnet_group_name" {
  description = "Development database subnet group."
  value       = module.networking.db_subnet_group_name
}

output "nat_gateway_ids" {
  description = "Development NAT Gateway IDs."
  value       = module.networking.nat_gateway_ids
}

output "ecr_repository_url" {
  description = "Development ECR repository URL."
  value       = module.ecr.repository_url
}

output "ecs_cluster_name" {
  description = "Development ECS cluster name."
  value       = module.ecs_cluster.cluster_name
}

output "alb_dns_name" {
  description = "Development Application Load Balancer DNS name."
  value       = module.alb.load_balancer_dns_name
}

output "alb_target_group_arn" {
  description = "Application target-group ARN."
  value       = module.alb.target_group_arn
}

output "alb_security_group_id" {
  description = "ALB security group ID."
  value       = module.security.alb_security_group_id
}

output "ecs_tasks_security_group_id" {
  description = "ECS tasks security group ID."
  value       = module.security.ecs_tasks_security_group_id
}

output "database_security_group_id" {
  description = "Database security group ID."
  value       = module.security.database_security_group_id
}

output "ecs_service_name" {
  description = "Development ECS service name."
  value       = module.ecs_service.service_name
}

output "ecs_task_definition_arn" {
  description = "Current ECS task-definition ARN."
  value       = module.ecs_service.task_definition_arn
}

output "ecs_task_definition_family" {
  description = "ECS task-definition family."
  value       = module.ecs_service.task_definition_family
}

output "ecs_task_execution_role_arn" {
  description = "ECS task execution role ARN."
  value       = module.ecs_service.task_execution_role_arn
}

output "ecs_task_role_arn" {
  description = "Application task role ARN."
  value       = module.ecs_service.task_role_arn
}

output "application_log_group_name" {
  description = "Application CloudWatch log-group name."
  value       = module.ecs_service.application_log_group_name
}

output "ecs_autoscaling_resource_id" {
  description = "ECS autoscaling resource identifier."
  value       = module.ecs_service.autoscaling_resource_id
}

output "ecs_service_arn" {
  description = "Development ECS service ARN."
  value       = module.ecs_service.service_arn
}

output "ecs_cluster_arn" {
  description = "ECS cluster ARN."
  value       = module.ecs_cluster.cluster_arn
}

output "github_deploy_role_arn" {
  description = "IAM role assumed by GitHub Actions."
  value       = module.github_oidc.github_deploy_role_arn
}

output "github_oidc_provider_arn" {
  description = "GitHub OIDC provider ARN."
  value       = module.github_oidc.github_oidc_provider_arn
}

output "github_oidc_subject" {
  description = "GitHub identity permitted to assume the AWS deployment role."
  value       = module.github_oidc.github_oidc_subject
}
