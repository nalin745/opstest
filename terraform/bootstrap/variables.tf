variable "project_name" {
  description = "Name of the project."
  type        = string
  default     = "rightmo-devops-assessment"

  validation {
    condition     = length(var.project_name) >= 3
    error_message = "project_name must contain at least three characters."
  }
}

variable "repository_name" {
  description = "GitHub repository name used for resource tagging."
  type        = string
  default     = "rightmo-devops-assessment"
}

variable "aws_region" {
  description = "AWS region where shared Terraform backend resources will be created."
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_force_destroy" {
  description = "Allow deletion of the state bucket even when it contains objects. Keep false for safety."
  type        = bool
  default     = false
}

variable "state_noncurrent_version_retention_days" {
  description = "Number of days to retain noncurrent Terraform state versions."
  type        = number
  default     = 90

  validation {
    condition     = var.state_noncurrent_version_retention_days >= 30
    error_message = "State versions must be retained for at least 30 days."
  }
}
