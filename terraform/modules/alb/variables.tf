variable "project_name" {
  description = "Project name used in resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "vpc_id" {
  description = "VPC in which the target group is created."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs used by the internet-facing ALB."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "The ALB requires at least two public subnets."
  }
}

variable "alb_security_group_id" {
  description = "Security group attached to the ALB."
  type        = string
}

variable "application_port" {
  description = "Port on which ECS tasks receive application traffic."
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "Application endpoint used for target health checks."
  type        = string
  default     = "/health"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS. Leave null for HTTP-only development."
  type        = string
  default     = null
}

variable "enable_deletion_protection" {
  description = "Protect the ALB from accidental deletion."
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "Optional S3 bucket used for ALB access logs."
  type        = string
  default     = null
}

variable "idle_timeout" {
  description = "ALB connection idle timeout in seconds."
  type        = number
  default     = 60
}

variable "common_tags" {
  description = "Additional tags applied to resources."
  type        = map(string)
  default     = {}
}
