variable "zone_id" {
  description = "Route 53 hosted zone ID"
  type        = string
}

variable "record_name" {
  description = "DNS record name (e.g., \"nonprod.therj.link\")"
  type        = string
}

variable "alias_dns_name" {
  description = "DNS name for alias target (ALB or CloudFront distribution)"
  type        = string
}

variable "alias_zone_id" {
  description = "Hosted zone ID for alias target (ALB or CloudFront distribution)"
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
