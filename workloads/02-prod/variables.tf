variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "ap-southeast-1"
}

variable "prod_account_id" {
  description = "Prod AWS account ID"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.2.101.0/24", "10.2.102.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.2.1.0/24", "10.2.2.0/24"]
}

variable "availability_zones" {
  description = "Availability zones for subnet placement"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "container_image_tag" {
  description = "Container image tag for ECS task"
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
