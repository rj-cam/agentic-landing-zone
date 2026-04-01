###############################################################################
# Remote State Data Sources
###############################################################################

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
# Workload — Production
###############################################################################

module "workload" {
  source = "../../modules/workload"

  providers = {
    aws     = aws
    aws.dns = aws.dns
  }

  environment               = "prod"
  domain_name               = "prod.therj.link"
  aws_region                = var.aws_region
  vpc_cidr_primary          = "10.2.0.0/24"
  vpc_cidr_secondary        = "10.2.8.0/21"
  availability_zones        = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  tgw_subnet_cidrs          = ["10.2.0.0/28", "10.2.0.16/28", "10.2.0.32/28"]
  web_alb_subnet_cidrs      = ["10.2.0.64/27", "10.2.0.96/27", "10.2.0.128/27"]
  web_nlb_subnet_cidrs      = ["10.2.0.160/27", "10.2.0.192/27", "10.2.0.224/27"]
  app_endpoint_subnet_cidrs = ["10.2.8.0/27", "10.2.8.32/27", "10.2.8.64/27"]
  app_compute_subnet_cidrs  = ["10.2.10.0/23", "10.2.12.0/23", "10.2.14.0/23"]
  data_subnet_cidrs         = ["10.2.8.96/27", "10.2.8.128/27", "10.2.8.160/27"]
  compute_az_count          = 2
  desired_count             = 2
  container_image_tag       = "latest"
  transit_gateway_id        = data.terraform_remote_state.networking.outputs.transit_gateway_id
  ecr_repository_url        = data.terraform_remote_state.shared_services.outputs.ecr_repository_url
  hosted_zone_id            = data.terraform_remote_state.networking.outputs.hosted_zone_id
  dns_role_arn              = data.terraform_remote_state.networking.outputs.dns_role_arn
  github_org                = "rj-cam"
  github_repo               = "agentic-landing-zone"
}
