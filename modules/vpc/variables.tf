variable "vpc_cidr_primary" {
  description = "Primary VPC CIDR block (/24 — infrastructure subnets)"
  type        = string
}

variable "vpc_cidr_secondary" {
  description = "Secondary VPC CIDR block (/21 — workload subnets)"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones (3 AZs)"
  type        = list(string)
}

variable "tgw_subnet_cidrs" {
  description = "Transit Gateway subnet CIDRs (/28 × 3 AZs)"
  type        = list(string)
}

variable "web_alb_subnet_cidrs" {
  description = "Web ALB subnet CIDRs (/27 × 3 AZs, public)"
  type        = list(string)
}

variable "web_nlb_subnet_cidrs" {
  description = "Web NLB subnet CIDRs (/27 × 3 AZs, reserved)"
  type        = list(string)
}

variable "app_endpoint_subnet_cidrs" {
  description = "App endpoint subnet CIDRs (/27 × 3 AZs — VPC endpoints, EFS, bastion)"
  type        = list(string)
}

variable "app_compute_subnet_cidrs" {
  description = "App compute subnet CIDRs (/23 × 3 AZs — ECS/EKS tasks)"
  type        = list(string)
}

variable "data_subnet_cidrs" {
  description = "Data subnet CIDRs (/27 × 3 AZs — RDS, reserved)"
  type        = list(string)
}

variable "transit_gateway_id" {
  description = "Transit Gateway ID for attachment"
  type        = string
}

variable "compute_az_count" {
  description = "Number of AZs to deploy Fargate tasks and VPC endpoints into (1-3)"
  type        = number
  default     = 1
}

variable "aws_region" {
  description = "AWS region for VPC endpoint service names"
  type        = string
  default     = "ap-southeast-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
