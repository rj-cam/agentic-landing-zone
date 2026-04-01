terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Management account provider (default) - for CloudTrail
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project     = "landing-zone"
      Environment = "management"
      ManagedBy   = "terraform"
    }
  }
}

# Log Archive account provider
provider "aws" {
  alias  = "log_archive"
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::${var.log_archive_account_id}:role/OrganizationAccountAccessRole"
  }
  default_tags {
    tags = {
      Project     = "landing-zone"
      Environment = "log-archive"
      ManagedBy   = "terraform"
    }
  }
}
