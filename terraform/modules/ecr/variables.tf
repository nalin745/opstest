variable "project_name" {
  description = "Project name used in resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "repository_name" {
  description = "Name assigned to the ECR repository."
  type        = string
  default     = "application"
}

variable "image_tag_mutability" {
  description = "Whether image tags can be overwritten."
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition = contains(
      ["MUTABLE", "IMMUTABLE"],
      var.image_tag_mutability
    )

    error_message = "image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Scan container images when pushed."
  type        = bool
  default     = true
}

variable "untagged_image_retention_count" {
  description = "Number of untagged images retained."
  type        = number
  default     = 5
}

variable "release_image_retention_count" {
  description = "Number of release images retained."
  type        = number
  default     = 30
}

variable "force_delete" {
  description = "Delete repository even when it contains images."
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Additional tags applied to resources."
  type        = map(string)
  default     = {}
}
