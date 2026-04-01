variable "zone_id" {
  description = "Route 53 hosted zone ID"
  type        = string
}

variable "record_name" {
  description = "DNS record name (e.g., \"nonprod.therj.link\")"
  type        = string
}

variable "alb_dns_name" {
  description = "ALB DNS name for alias target"
  type        = string
}

variable "alb_zone_id" {
  description = "ALB hosted zone ID for alias target"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "assume_role_arn" {
  description = "IAM role ARN to assume for cross-account Route 53 access"
  type        = string
}
