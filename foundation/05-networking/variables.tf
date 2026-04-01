variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "shared_services_account_id" {
  description = "AWS account ID for the Shared Services account"
  type        = string
}

variable "nonprod_account_id" {
  description = "AWS account ID for the Non-Production account"
  type        = string
}

variable "prod_account_id" {
  description = "AWS account ID for the Production account"
  type        = string
}

variable "hosted_zone_id" {
  description = "Route 53 hosted zone ID for the domain"
  type        = string
  default     = "Z02874271LXAPI4H9WD4L"
}

variable "domain_name" {
  description = "Domain name managed in Route 53"
  type        = string
  default     = "therj.link"
}
