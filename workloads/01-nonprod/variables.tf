variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "nonprod_account_id" {
  description = "Non-prod AWS account ID"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "nonprod"
}

variable "vpc_cidr_primary" {
  description = "Primary VPC CIDR (/24 infrastructure)"
  type        = string
  default     = "10.1.0.0/24"
}

variable "vpc_cidr_secondary" {
  description = "Secondary VPC CIDR (/21 workloads)"
  type        = string
  default     = "10.1.4.0/21"
}

variable "availability_zones" {
  description = "Availability zones (3 AZs)"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}

variable "tgw_subnet_cidrs" {
  description = "Transit Gateway subnet CIDRs"
  type        = list(string)
  default     = ["10.1.0.0/28", "10.1.0.16/28", "10.1.0.32/28"]
}

variable "web_alb_subnet_cidrs" {
  description = "Web ALB subnet CIDRs (public)"
  type        = list(string)
  default     = ["10.1.0.64/27", "10.1.0.96/27", "10.1.0.128/27"]
}

variable "web_nlb_subnet_cidrs" {
  description = "Web NLB subnet CIDRs (reserved)"
  type        = list(string)
  default     = ["10.1.0.160/27", "10.1.0.192/27", "10.1.0.224/27"]
}

variable "app_endpoint_subnet_cidrs" {
  description = "App endpoint subnet CIDRs"
  type        = list(string)
  default     = ["10.1.4.0/27", "10.1.4.32/27", "10.1.4.64/27"]
}

variable "app_compute_subnet_cidrs" {
  description = "App compute subnet CIDRs"
  type        = list(string)
  default     = ["10.1.6.0/23", "10.1.8.0/23", "10.1.10.0/23"]
}

variable "data_subnet_cidrs" {
  description = "Data subnet CIDRs (reserved)"
  type        = list(string)
  default     = ["10.1.4.96/27", "10.1.4.128/27", "10.1.4.160/27"]
}

variable "compute_az_count" {
  description = "Number of AZs for Fargate tasks and VPC endpoints"
  type        = number
  default     = 1
}

variable "container_image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
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
