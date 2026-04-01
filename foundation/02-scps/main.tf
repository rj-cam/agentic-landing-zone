###############################################################################
# Remote State — Organization layer
###############################################################################

data "terraform_remote_state" "organization" {
  backend = "s3"

  config = {
    bucket = "rj-landing-zone-tfstate"
    key    = "foundation/01-organization/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

###############################################################################
# Locals — OU and account IDs from remote state
###############################################################################

locals {
  root_id                = data.terraform_remote_state.organization.outputs.root_id
  ou_ids                 = data.terraform_remote_state.organization.outputs.ou_ids
  account_ids            = data.terraform_remote_state.organization.outputs.account_ids
  log_archive_account_id = local.account_ids["log_archive"]
}
