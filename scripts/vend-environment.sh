#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

if [ $# -lt 1 ]; then
  echo "Usage: $0 <environment-name>"
  echo ""
  echo "Creates a workload directory from environments.yaml."
  echo "The environment must be defined in environments.yaml first."
  exit 1
fi

ENV_NAME="$1"
YAML_FILE="$ROOT_DIR/environments.yaml"

# Check environment exists in YAML (simple grep — no yq dependency)
if ! grep -q "^  ${ENV_NAME}:" "$YAML_FILE"; then
  echo "ERROR: Environment '${ENV_NAME}' not found in environments.yaml"
  echo "Add it to environments.yaml first, then re-run."
  exit 1
fi

# Parse values from YAML (simple awk — no yq dependency)
parse_yaml_value() {
  local key="$1"
  awk "/^  ${ENV_NAME}:/{found=1} found && /    ${key}:/{print \$2; exit}" "$YAML_FILE" | tr -d '"' | tr -d "'"
}

CIDR_INDEX=$(parse_yaml_value "cidr_index")
DOMAIN=$(parse_yaml_value "domain")
COMPUTE_AZ_COUNT=$(parse_yaml_value "compute_az_count")
DESIRED_COUNT=$(parse_yaml_value "desired_count")

if [ -z "$CIDR_INDEX" ] || [ -z "$DOMAIN" ]; then
  echo "ERROR: Could not parse cidr_index or domain for '${ENV_NAME}' from environments.yaml"
  exit 1
fi

# Determine workload directory number (next available)
EXISTING=$(ls -d "$ROOT_DIR/workloads/"*/ 2>/dev/null | wc -l)
NEXT_NUM=$(printf "%02d" $((EXISTING + 1)))
WORKLOAD_DIR="$ROOT_DIR/workloads/${NEXT_NUM}-${ENV_NAME}"

if [ -d "$WORKLOAD_DIR" ]; then
  echo "Directory already exists: $WORKLOAD_DIR"
  echo "Nothing to do."
  exit 0
fi

echo "=== Vending environment: ${ENV_NAME} ==="
echo "  CIDR index:      ${CIDR_INDEX} (10.${CIDR_INDEX}.x.x)"
echo "  Domain:          ${DOMAIN}"
echo "  Compute AZs:     ${COMPUTE_AZ_COUNT}"
echo "  Desired count:   ${DESIRED_COUNT}"
echo "  Directory:       ${WORKLOAD_DIR}"
echo ""

mkdir -p "$WORKLOAD_DIR"

# backend.tf
cat > "$WORKLOAD_DIR/backend.tf" <<EOF
terraform {
  backend "s3" {
    bucket         = "rj-landing-zone-tfstate"
    key            = "workloads/${NEXT_NUM}-${ENV_NAME}/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "rj-landing-zone-tflock"
    encrypt        = true
  }
}
EOF

# variables.tf
cat > "$WORKLOAD_DIR/variables.tf" <<EOF
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "account_id" {
  description = "AWS account ID for this workload"
  type        = string
}
EOF

# providers.tf
cat > "$WORKLOAD_DIR/providers.tf" <<PROVEOF
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
    role_arn = "arn:aws:iam::\${var.account_id}:role/OrganizationAccountAccessRole"
  }
  default_tags {
    tags = {
      Project     = "landing-zone"
      Environment = "${ENV_NAME}"
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
PROVEOF

# main.tf
cat > "$WORKLOAD_DIR/main.tf" <<EOF
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
# Workload — ${ENV_NAME}
###############################################################################

module "workload" {
  source = "../../modules/workload"

  providers = {
    aws     = aws
    aws.dns = aws.dns
  }

  environment               = "${ENV_NAME}"
  domain_name               = "${DOMAIN}"
  aws_region                = var.aws_region
  vpc_cidr_primary          = "10.${CIDR_INDEX}.0.0/24"
  vpc_cidr_secondary        = "10.${CIDR_INDEX}.8.0/21"
  availability_zones        = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  tgw_subnet_cidrs          = ["10.${CIDR_INDEX}.0.0/28", "10.${CIDR_INDEX}.0.16/28", "10.${CIDR_INDEX}.0.32/28"]
  web_alb_subnet_cidrs      = ["10.${CIDR_INDEX}.0.64/27", "10.${CIDR_INDEX}.0.96/27", "10.${CIDR_INDEX}.0.128/27"]
  web_nlb_subnet_cidrs      = ["10.${CIDR_INDEX}.0.160/27", "10.${CIDR_INDEX}.0.192/27", "10.${CIDR_INDEX}.0.224/27"]
  app_endpoint_subnet_cidrs = ["10.${CIDR_INDEX}.8.0/27", "10.${CIDR_INDEX}.8.32/27", "10.${CIDR_INDEX}.8.64/27"]
  app_compute_subnet_cidrs  = ["10.${CIDR_INDEX}.10.0/23", "10.${CIDR_INDEX}.12.0/23", "10.${CIDR_INDEX}.14.0/23"]
  data_subnet_cidrs         = ["10.${CIDR_INDEX}.8.96/27", "10.${CIDR_INDEX}.8.128/27", "10.${CIDR_INDEX}.8.160/27"]
  compute_az_count          = ${COMPUTE_AZ_COUNT}
  desired_count             = ${DESIRED_COUNT}
  container_image_tag       = "latest"
  transit_gateway_id        = data.terraform_remote_state.networking.outputs.transit_gateway_id
  ecr_repository_url        = data.terraform_remote_state.shared_services.outputs.ecr_repository_url
  hosted_zone_id            = data.terraform_remote_state.networking.outputs.hosted_zone_id
  dns_role_arn              = data.terraform_remote_state.networking.outputs.dns_role_arn
  github_org                = "rj-cam"
  github_repo               = "agentic-landing-zone"
}
EOF

# outputs.tf
cat > "$WORKLOAD_DIR/outputs.tf" <<EOF
output "vpc_id" {
  description = "ID of the workload VPC"
  value       = module.workload.vpc_id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.workload.alb_dns_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.workload.ecs_cluster_name
}

output "app_url" {
  description = "Application URL"
  value       = module.workload.app_url
}

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions deploy role"
  value       = module.workload.github_actions_role_arn
}
EOF

echo "=== Environment '${ENV_NAME}' vended ==="
echo ""
echo "Next steps:"
echo "  1. Run: scripts/provision-foundation.sh  (creates the account)"
echo "  2. Run: cd ${WORKLOAD_DIR} && terraform init && terraform apply -var=\"account_id=\$(terraform -chdir=../../foundation/01-organization output -raw workload_account_ids | jq -r '.${ENV_NAME}')\""
echo "  3. Or add to provision-workloads.sh for automated deployment"
