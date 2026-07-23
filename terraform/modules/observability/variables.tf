variable "project_name" {
  description = "Project name used in observability resource names."
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

variable "aws_region" {
  description = "AWS region containing the monitored resources."
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service."
  type        = string
}

variable "alb_arn_suffix" {
  description = "Application Load Balancer ARN suffix used as a CloudWatch metric dimension."
  type        = string
}

variable "target_group_arn_suffix" {
  description = "Target group ARN suffix used as a CloudWatch metric dimension."
  type        = string
}

variable "application_log_group_name" {
  description = "Application CloudWatch log-group name."
  type        = string
}

variable "alert_email_addresses" {
  description = "Email addresses subscribed to operational alerts."
  type        = set(string)
  default     = []
}

variable "cpu_alarm_threshold" {
  description = "CPU utilization percentage that triggers an alarm."
  type        = number
  default     = 80
}

variable "memory_alarm_threshold" {
  description = "Memory utilization percentage that triggers an alarm."
  type        = number
  default     = 85
}

variable "target_5xx_threshold" {
  description = "Target HTTP 5XX count that triggers an alarm."
  type        = number
  default     = 5
}

variable "response_time_threshold_seconds" {
  description = "Average ALB target-response time threshold."
  type        = number
  default     = 2
}

variable "minimum_healthy_host_count" {
  description = "Minimum acceptable number of healthy ALB targets."
  type        = number
  default     = 1
}

variable "alarm_evaluation_periods" {
  description = "Number of evaluation periods required before an alarm changes state."
  type        = number
  default     = 2
}

variable "alarm_period_seconds" {
  description = "CloudWatch alarm evaluation period."
  type        = number
  default     = 60
}

variable "common_tags" {
  description = "Additional tags applied to observability resources."
  type        = map(string)
  default     = {}
}
