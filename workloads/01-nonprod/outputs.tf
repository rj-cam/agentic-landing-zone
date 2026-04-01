output "vpc_id" {
  description = "ID of the workload VPC"
  value       = module.workload.vpc_id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.workload.alb_dns_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.workload.ecs_cluster_name
}

output "app_url" {
  description = "Application URL"
  value       = module.workload.app_url
}

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions deploy role"
  value       = module.workload.github_actions_role_arn
}
