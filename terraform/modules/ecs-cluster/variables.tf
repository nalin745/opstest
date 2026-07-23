variable "project_name" {
  description = "Project name used in resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights."
  type        = bool
  default     = true
}

variable "enable_execute_command" {
  description = "Prepare cluster logging for ECS Exec."
  type        = bool
  default     = true
}

variable "execute_command_log_retention_days" {
  description = "CloudWatch retention for ECS Exec logs."
  type        = number
  default     = 30
}

variable "fargate_base" {
  description = "Minimum tasks placed on standard Fargate."
  type        = number
  default     = 1
}

variable "fargate_weight" {
  description = "Relative weight assigned to standard Fargate."
  type        = number
  default     = 1
}

variable "fargate_spot_weight" {
  description = "Relative weight assigned to Fargate Spot."
  type        = number
  default     = 0
}

variable "common_tags" {
  description = "Additional tags applied to resources."
  type        = map(string)
  default     = {}
}
