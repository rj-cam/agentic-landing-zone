terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::${var.account_id}:role/OrganizationAccountAccessRole"
  }
  default_tags {
    tags = {
      Project     = "landing-zone"
      Environment = "prod"
      ManagedBy   = "terraform"
    }
  }
}

provider "aws" {
  alias  = "dns"
  region = var.aws_region
  assume_role {
    role_arn = data.terraform_remote_state.networking.outputs.dns_role_arn
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::${var.account_id}:role/OrganizationAccountAccessRole"
  }
  default_tags {
    tags = {
      Project     = "landing-zone"
      Environment = "prod"
      ManagedBy   = "terraform"
    }
  }
}
