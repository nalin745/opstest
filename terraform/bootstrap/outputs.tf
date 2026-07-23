output "terraform_state_bucket_name" {
  description = "S3 bucket used for Terraform remote state."
  value       = aws_s3_bucket.terraform_state.id
}

output "terraform_state_bucket_arn" {
  description = "ARN of the Terraform remote state bucket."
  value       = aws_s3_bucket.terraform_state.arn
}

output "terraform_state_kms_key_arn" {
  description = "ARN of the KMS key used for Terraform state encryption."
  value       = aws_kms_key.terraform_state.arn
}

output "terraform_state_kms_alias" {
  description = "Alias of the Terraform state KMS key."
  value       = aws_kms_alias.terraform_state.name
}

output "aws_account_id" {
  description = "AWS account where the backend resources were created."
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region containing the state backend."
  value       = var.aws_region
}

output "backend_configuration_example" {
  description = "Example backend configuration for environment root modules."

  value = <<-EOT
    terraform {
      backend "s3" {
        bucket       = "${aws_s3_bucket.terraform_state.id}"
        key          = "ENVIRONMENT/terraform.tfstate"
        region       = "${var.aws_region}"
        encrypt      = true
        kms_key_id   = "${aws_kms_key.terraform_state.arn}"
        use_lockfile = true
      }
    }
  EOT
}
