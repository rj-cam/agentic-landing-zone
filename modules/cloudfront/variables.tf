variable "alb_arn" {
  description = "ARN of the internal ALB (used as VPC origin target)"
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the internal ALB"
  type        = string
}

variable "domain_name" {
  description = "Custom domain name for the CloudFront distribution (e.g., nonprod.therj.link)"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN in us-east-1 (required by CloudFront)"
  type        = string
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
