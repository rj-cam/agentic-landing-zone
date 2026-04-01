output "vpc_id" {
  description = "ID of the nonprod VPC"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "app_url" {
  description = "Application URL"
  value       = "https://nonprod.therj.link"
}

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions deploy role"
  value       = aws_iam_role.github_actions_deploy.arn
}
