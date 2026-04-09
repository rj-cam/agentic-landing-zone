terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  alias  = "dns"
  region = var.aws_region
  assume_role {
    role_arn = var.assume_role_arn
  }
}

resource "aws_route53_record" "this" {
  provider = aws.dns
  zone_id  = var.zone_id
  name     = var.record_name
  type     = "A"

  alias {
    name                   = var.alias_dns_name
    zone_id                = var.alias_zone_id
    evaluate_target_health = true
  }
}
