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
