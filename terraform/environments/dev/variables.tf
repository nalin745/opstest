variable "project_name" {
  description = "Name of the project."
  type        = string
  default     = "rightmo-devops-assessment"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region used by the environment."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block assigned to the development VPC."
  type        = string
  default     = "10.10.0.0/16"
}

variable "availability_zones" {
  description = "Availability Zones used by the development environment."
  type        = list(string)

  default = [
    "us-east-1a",
    "us-east-1b"
  ]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks."

  type = list(string)

  default = [
    "10.10.0.0/24",
    "10.10.1.0/24"
  ]
}

variable "private_app_subnet_cidrs" {
  description = "Private application subnet CIDR blocks."

  type = list(string)

  default = [
    "10.10.10.0/24",
    "10.10.11.0/24"
  ]
}

variable "private_db_subnet_cidrs" {
  description = "Private database subnet CIDR blocks."

  type = list(string)

  default = [
    "10.10.20.0/24",
    "10.10.21.0/24"
  ]
}

variable "application_port" {
  description = "Port exposed by the application container."
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "Application health-check endpoint."
  type        = string
  default     = "/health"
}

variable "application_image_uri" {
  description = "Immutable ECR image URI deployed to ECS."
  type        = string

  validation {
    condition = (
      length(trimspace(var.application_image_uri)) > 0 &&
      !endswith(var.application_image_uri, ":latest")
    )

    error_message = "application_image_uri must be populated and cannot use latest."
  }
}

variable "application_version" {
  description = "Application release version."
  type        = string
  default     = "development"
}

variable "desired_task_count" {
  description = "Initial desired ECS task count."
  type        = number
  default     = 1
}

variable "github_owner" {
  description = "GitHub organization or username."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository name."
  type        = string
  default     = "rightmo-devops-assessment"
}

variable "github_environment_name" {
  description = "GitHub Environment used for development deployments."
  type        = string
  default     = "development"
}

variable "create_github_oidc_provider" {
  description = "Create the GitHub OIDC provider in this AWS account."
  type        = bool
  default     = true
}

variable "existing_github_oidc_provider_arn" {
  description = "Existing GitHub OIDC provider ARN."
  type        = string
  default     = null
}

variable "github_owner_id" {
  description = "Immutable GitHub owner ID."
  type        = string
}

variable "github_repository_id" {
  description = "Immutable GitHub repository ID."
  type        = string
}

variable "alert_email_addresses" {
  description = "Email addresses receiving development operational alerts."
  type        = set(string)
  default     = []
}