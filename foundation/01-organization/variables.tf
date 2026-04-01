variable "aws_region" {
  description = "AWS region for the provider"
  type        = string
  default     = "ap-southeast-1"
}

variable "security_account_email" {
  description = "Email address for the Security account"
  type        = string
  default     = "rj.camarillo+security@gmail.com"
}

variable "log_archive_account_email" {
  description = "Email address for the Log Archive account"
  type        = string
  default     = "rj.camarillo+logarchive@gmail.com"
}

variable "shared_services_account_email" {
  description = "Email address for the Shared Services account"
  type        = string
  default     = "rj.camarillo+shared@gmail.com"
}

variable "nonprod_account_email" {
  description = "Email address for the Non-Prod account"
  type        = string
  default     = "rj.camarillo+nonprod@gmail.com"
}

variable "prod_account_email" {
  description = "Email address for the Prod account"
  type        = string
  default     = "rj.camarillo+prod@gmail.com"
}
