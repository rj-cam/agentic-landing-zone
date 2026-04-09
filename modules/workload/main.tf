terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.0"
      configuration_aliases = [aws.dns, aws.us_east_1]
    }
  }
}

###############################################################################
# VPC — 5-tier microsegmented network
###############################################################################

module "vpc" {
  source = "../vpc"

  vpc_cidr_primary          = var.vpc_cidr_primary
  vpc_cidr_secondary        = var.vpc_cidr_secondary
  availability_zones        = var.availability_zones
  tgw_subnet_cidrs          = var.tgw_subnet_cidrs
  web_alb_subnet_cidrs      = var.web_alb_subnet_cidrs
  web_nlb_subnet_cidrs      = var.web_nlb_subnet_cidrs
  app_endpoint_subnet_cidrs = var.app_endpoint_subnet_cidrs
  app_compute_subnet_cidrs  = var.app_compute_subnet_cidrs
  data_subnet_cidrs         = var.data_subnet_cidrs
  transit_gateway_id        = var.transit_gateway_id
  compute_az_count          = var.compute_az_count
  aws_region                = var.aws_region
  environment               = var.environment
  tags                      = {}
}

###############################################################################
# ACM Certificate + DNS Validation — regional (for ALB)
###############################################################################

resource "aws_acm_certificate" "this" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  provider = aws.dns

  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = var.hosted_zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

###############################################################################
# ACM Certificate — us-east-1 (required by CloudFront)
###############################################################################

resource "aws_acm_certificate" "cloudfront" {
  provider          = aws.us_east_1
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# DNS validation records are the same for both certs (same domain, same DNS method),
# so the regional cert validation records already satisfy this cert too.
resource "aws_acm_certificate_validation" "cloudfront" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.cloudfront.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

###############################################################################
# ALB — internal, HTTPS with TLS 1.3
###############################################################################

module "alb" {
  source = "../alb"

  name            = "${var.environment}-alb"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.web_alb_subnet_ids
  certificate_arn = aws_acm_certificate_validation.this.certificate_arn
  internal        = true
  environment     = var.environment
  tags            = {}
}

###############################################################################
# CloudFront — VPC Origin to internal ALB (ADR-012)
###############################################################################

module "cloudfront" {
  source = "../cloudfront"

  alb_arn             = module.alb.alb_arn
  alb_dns_name        = module.alb.alb_dns_name
  domain_name         = var.domain_name
  acm_certificate_arn = aws_acm_certificate_validation.cloudfront.certificate_arn
  environment         = var.environment
  tags                = {}
}

###############################################################################
# ECS Fargate Service — ARM64/Graviton
###############################################################################

module "ecs" {
  source = "../ecs-fargate-service"

  cluster_name          = "sample-${var.environment}"
  service_name          = "sample-service"
  container_image       = "${var.ecr_repository_url}:${var.container_image_tag}"
  container_port        = 80
  cpu                   = 256
  memory                = 512
  desired_count         = var.desired_count
  subnet_ids            = slice(module.vpc.app_compute_subnet_ids, 0, var.compute_az_count)
  vpc_id                = module.vpc.vpc_id
  target_group_arn      = module.alb.target_group_arn
  alb_security_group_id = module.alb.security_group_id
  environment           = var.environment
  aws_region            = var.aws_region
  tags                  = {}
}

###############################################################################
# DNS Record — cross-account Route 53, points to CloudFront
###############################################################################

module "dns" {
  source = "../dns-record"

  zone_id         = var.hosted_zone_id
  record_name     = var.domain_name
  alias_dns_name  = module.cloudfront.distribution_domain_name
  alias_zone_id   = module.cloudfront.distribution_hosted_zone_id
  aws_region      = var.aws_region
  assume_role_arn = var.dns_role_arn
}
