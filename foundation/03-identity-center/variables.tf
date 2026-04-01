variable "aws_region" {
  description = "AWS region for Identity Center"
  type        = string
  default     = "ap-southeast-1"
}

variable "admin_user_name" {
  description = "Local Identity Center user display name"
  type        = string
  default     = "admin"
}

variable "admin_user_email" {
  description = "Local Identity Center user email"
  type        = string
  default     = "rj.camarillo@gmail.com"
}

variable "admin_given_name" {
  description = "Admin user given (first) name"
  type        = string
  default     = "RJ"
}

variable "admin_family_name" {
  description = "Admin user family (last) name"
  type        = string
  default     = "Camarillo"
}
