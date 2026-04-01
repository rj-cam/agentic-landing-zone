variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "account_id" {
  description = "AWS account ID for this workload"
  type        = string
}
