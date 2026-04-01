variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "log_archive_account_id" {
  description = "Log Archive account ID"
  type        = string
}

variable "log_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
  default     = "landing-zone-cloudtrail-logs"
}

variable "log_retention_days" {
  description = "Number of days before log expiration"
  type        = number
  default     = 365
}

variable "glacier_transition_days" {
  description = "Number of days before transition to Glacier"
  type        = number
  default     = 90
}
