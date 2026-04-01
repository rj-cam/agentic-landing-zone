variable "aws_region" {
  description = "AWS region for shared services resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "shared_services_account_id" {
  description = "AWS account ID for the shared services account"
  type        = string
}

variable "github_org" {
  description = "GitHub username/org"
  type        = string
  default     = "rj-cam"
}

variable "github_repo" {
  description = "GitHub repo name"
  type        = string
  default     = "agentic-landing-zone"
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "landing-zone/httpd"
}
