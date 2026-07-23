terraform {
  backend "s3" {
    bucket       = "rightmo-devops-assessment-tfstate-408115211882-c27db5ce"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    kms_key_id   = "arn:aws:kms:us-east-1:408115211882:key/594dcbf3-dee2-4fc3-a6d3-981e000846c8"
    use_lockfile = true
  }
}
