variable "project_name" {
  description = "Project name used in IAM resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "aws_account_id" {
  description = "AWS account ID containing the deployment resources."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "aws_account_id must contain exactly 12 digits."
  }
}

variable "aws_region" {
  description = "AWS region containing the deployment resources."
  type        = string
}

variable "github_owner" {
  description = "GitHub organization or username."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository name."
  type        = string
}

variable "github_environment_name" {
  description = "GitHub Environment allowed to assume the deployment role."
  type        = string
  default     = "development"
}

variable "create_oidc_provider" {
  description = "Create the GitHub OIDC provider in this AWS account."
  type        = bool
  default     = true
}

variable "existing_oidc_provider_arn" {
  description = "Existing GitHub OIDC provider ARN when creation is disabled."
  type        = string
  default     = null
}

variable "ecr_repository_arn" {
  description = "ARN of the ECR repository used by the deployment workflow."
  type        = string
}

variable "ecs_cluster_arn" {
  description = "ARN of the ECS cluster."
  type        = string
}

variable "ecs_service_arn" {
  description = "ARN of the ECS service updated by the workflow."
  type        = string
}

variable "task_definition_family" {
  description = "ECS task-definition family managed by the workflow."
  type        = string
}

variable "task_execution_role_arn" {
  description = "ECS task execution role that GitHub may pass to ECS."
  type        = string
}

variable "task_role_arn" {
  description = "Application task role that GitHub may pass to ECS."
  type        = string
}

variable "common_tags" {
  description = "Additional resource tags."
  type        = map(string)
  default     = {}
}
