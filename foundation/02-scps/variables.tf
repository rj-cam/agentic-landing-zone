variable "aws_region" {
  description = "AWS region for the provider"
  type        = string
  default     = "ap-southeast-1"
}

variable "log_archive_account_id" {
  description = "Log Archive account ID for the protect-log-archive SCP"
  type        = string
}

variable "log_archive_bucket_arn" {
  description = "Log Archive S3 bucket ARN"
  type        = string
}
