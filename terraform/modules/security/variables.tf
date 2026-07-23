variable "project_name" {
  description = "Project name used in resource naming."
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

variable "vpc_id" {
  description = "VPC in which security groups will be created."
  type        = string
}

variable "application_port" {
  description = "Port exposed by the application container."
  type        = number
  default     = 8080

  validation {
    condition = (
      var.application_port >= 1 &&
      var.application_port <= 65535
    )

    error_message = "application_port must be between 1 and 65535."
  }
}

variable "database_port" {
  description = "Database port used by the application."
  type        = number
  default     = 5432
}

variable "redis_port" {
  description = "Redis port used by the application."
  type        = number
  default     = 6379
}

variable "enable_database_security_group" {
  description = "Create the database security group."
  type        = bool
  default     = true
}

variable "enable_redis_security_group" {
  description = "Create the Redis security group."
  type        = bool
  default     = false
}

variable "allowed_http_cidrs" {
  description = "CIDR blocks allowed to access the ALB HTTP listener."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_https_cidrs" {
  description = "CIDR blocks allowed to access the ALB HTTPS listener."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_http" {
  description = "Allow inbound HTTP traffic to the ALB."
  type        = bool
  default     = true
}

variable "enable_https" {
  description = "Allow inbound HTTPS traffic to the ALB."
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Additional tags applied to resources."
  type        = map(string)
  default     = {}
}
