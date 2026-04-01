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
  value       = "http://nonprod.therj.link"
}
