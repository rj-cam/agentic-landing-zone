output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr_primary" {
  description = "Primary CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "vpc_cidr_secondary" {
  description = "Secondary CIDR block of the VPC"
  value       = var.vpc_cidr_secondary
}

output "tgw_subnet_ids" {
  description = "Transit Gateway subnet IDs"
  value       = aws_subnet.tgw[*].id
}

output "web_alb_subnet_ids" {
  description = "Web ALB subnet IDs (public)"
  value       = aws_subnet.web_alb[*].id
}

output "web_nlb_subnet_ids" {
  description = "Web NLB subnet IDs (reserved)"
  value       = aws_subnet.web_nlb[*].id
}

output "app_endpoint_subnet_ids" {
  description = "App endpoint subnet IDs (VPC endpoints, EFS, bastion)"
  value       = aws_subnet.app_endpoint[*].id
}

output "app_compute_subnet_ids" {
  description = "App compute subnet IDs (ECS/EKS tasks)"
  value       = aws_subnet.app_compute[*].id
}

output "data_subnet_ids" {
  description = "Data subnet IDs (RDS, reserved)"
  value       = aws_subnet.data[*].id
}

output "tgw_attachment_id" {
  description = "The ID of the Transit Gateway VPC attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment.this.id
}

output "vpc_endpoint_sg_id" {
  description = "Security group ID used by VPC endpoints"
  value       = aws_security_group.vpc_endpoints.id
}
