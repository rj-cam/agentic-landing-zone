variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "service_name" {
  description = "ECS service name"
  type        = string
}

variable "container_image" {
  description = "Full container image URI with tag"
  type        = string
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 80
}

variable "cpu" {
  description = "Fargate CPU units"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Fargate memory MiB"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of tasks"
  type        = number
  default     = 1
}

variable "subnet_ids" {
  description = "Private subnets for tasks"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for security group"
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN"
  type        = string
}

variable "alb_security_group_id" {
  description = "ALB SG ID for ingress rule"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "Region for CloudWatch logs"
  type        = string
  default     = "ap-southeast-1"
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
