provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "landing-zone"
      ManagedBy = "terraform"
      env       = "management"
    }
  }
}

provider "aws" {
  alias  = "shared_services"
  region = var.aws_region

  assume_role {
    role_arn = "arn:aws:iam::${var.shared_services_account_id}:role/OrganizationAccountAccessRole"
  }

  default_tags {
    tags = {
      Project   = "landing-zone"
      ManagedBy = "terraform"
      env       = "shared-services"
    }
  }
}
