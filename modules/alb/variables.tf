variable "name" {
  description = "ALB name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}

variable "container_port" {
  description = "Backend container port"
  type        = number
  default     = 80
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener (empty string = HTTP only)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
