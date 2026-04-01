################################################################################
# Remote State - Organization
################################################################################

data "terraform_remote_state" "organization" {
  backend = "s3"

  config = {
    bucket = "rj-landing-zone-tfstate"
    key    = "foundation/01-organization/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

locals {
  account_ids = data.terraform_remote_state.organization.outputs.account_ids
}

################################################################################
# Security Hardening
################################################################################

resource "aws_ebs_encryption_by_default" "this" {
  enabled = true
}
