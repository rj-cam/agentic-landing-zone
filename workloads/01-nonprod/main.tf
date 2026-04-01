###############################################################################
# Remote State Data Sources
###############################################################################

data "terraform_remote_state" "organization" {
  backend = "s3"
  config = {
    bucket = "rj-landing-zone-tfstate"
    key    = "foundation/01-organization/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "rj-landing-zone-tfstate"
    key    = "foundation/05-networking/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "shared_services" {
  backend = "s3"
  config = {
    bucket = "rj-landing-zone-tfstate"
    key    = "foundation/06-shared-services/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

###############################################################################
# VPC
###############################################################################

module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr_primary          = var.vpc_cidr_primary
  vpc_cidr_secondary        = var.vpc_cidr_secondary
  availability_zones        = var.availability_zones
  tgw_subnet_cidrs          = var.tgw_subnet_cidrs
  web_alb_subnet_cidrs      = var.web_alb_subnet_cidrs
  web_nlb_subnet_cidrs      = var.web_nlb_subnet_cidrs
  app_endpoint_subnet_cidrs = var.app_endpoint_subnet_cidrs
  app_compute_subnet_cidrs  = var.app_compute_subnet_cidrs
  data_subnet_cidrs         = var.data_subnet_cidrs
  transit_gateway_id        = data.terraform_remote_state.networking.outputs.transit_gateway_id
  compute_az_count          = var.compute_az_count
  aws_region                = var.aws_region
  environment               = var.environment
  tags                      = {}
}

###############################################################################
# ALB
###############################################################################

module "alb" {
  source = "../../modules/alb"

  name        = "${var.environment}-alb"
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.web_alb_subnet_ids
  environment = var.environment
  tags        = {}
}

###############################################################################
# ECS Fargate Service
###############################################################################

module "ecs" {
  source = "../../modules/ecs-fargate-service"

  cluster_name          = "sample-${var.environment}"
  service_name          = "sample-service"
  container_image       = "${data.terraform_remote_state.shared_services.outputs.ecr_repository_url}:${var.container_image_tag}"
  container_port        = 80
  cpu                   = 256
  memory                = 512
  desired_count         = 1
  subnet_ids            = slice(module.vpc.app_compute_subnet_ids, 0, var.compute_az_count)
  vpc_id                = module.vpc.vpc_id
  target_group_arn      = module.alb.target_group_arn
  alb_security_group_id = module.alb.security_group_id
  environment           = var.environment
  aws_region            = var.aws_region
  tags                  = {}
}

###############################################################################
# DNS Record
###############################################################################

module "dns" {
  source = "../../modules/dns-record"

  zone_id         = data.terraform_remote_state.networking.outputs.hosted_zone_id
  record_name     = "nonprod.therj.link"
  alb_dns_name    = module.alb.alb_dns_name
  alb_zone_id     = module.alb.alb_zone_id
  aws_region      = var.aws_region
  assume_role_arn = data.terraform_remote_state.networking.outputs.dns_role_arn
}
