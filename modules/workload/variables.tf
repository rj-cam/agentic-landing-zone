variable "environment" {
  description = "Environment name (nonprod, prod, staging, etc.)"
  type        = string
}

variable "domain_name" {
  description = "FQDN for this environment (e.g., nonprod.therj.link)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "vpc_cidr_primary" {
  description = "Primary VPC CIDR (/24 infrastructure)"
  type        = string
}

variable "vpc_cidr_secondary" {
  description = "Secondary VPC CIDR (/21 workloads)"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones (3 AZs)"
  type        = list(string)
}

variable "tgw_subnet_cidrs" {
  description = "Transit Gateway subnet CIDRs (/28 x 3)"
  type        = list(string)
}

variable "web_alb_subnet_cidrs" {
  description = "Web ALB subnet CIDRs (/27 x 3, public)"
  type        = list(string)
}

variable "web_nlb_subnet_cidrs" {
  description = "Web NLB subnet CIDRs (/27 x 3, reserved)"
  type        = list(string)
}

variable "app_endpoint_subnet_cidrs" {
  description = "App endpoint subnet CIDRs (/27 x 3)"
  type        = list(string)
}

variable "app_compute_subnet_cidrs" {
  description = "App compute subnet CIDRs (/23 x 3)"
  type        = list(string)
}

variable "data_subnet_cidrs" {
  description = "Data subnet CIDRs (/27 x 3, reserved)"
  type        = list(string)
}

variable "compute_az_count" {
  description = "Number of AZs for Fargate tasks and VPC endpoints (1-3)"
  type        = number
  default     = 1
}

variable "desired_count" {
  description = "Number of ECS Fargate tasks"
  type        = number
  default     = 1
}

variable "container_image_tag" {
  description = "Container image tag to deploy"
  type        = string
  default     = "latest"
}

variable "transit_gateway_id" {
  description = "Transit Gateway ID from networking layer"
  type        = string
}

variable "ecr_repository_url" {
  description = "ECR repository URL from shared services layer"
  type        = string
}

variable "hosted_zone_id" {
  description = "Route 53 hosted zone ID from networking layer"
  type        = string
}

variable "dns_role_arn" {
  description = "IAM role ARN for cross-account Route 53 access"
  type        = string
}

variable "github_org" {
  description = "GitHub username or organization"
  type        = string
  default     = "rj-cam"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "agentic-landing-zone"
}
