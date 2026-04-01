output "transit_gateway_id" {
  description = "ID of the Transit Gateway in Shared Services"
  value       = aws_ec2_transit_gateway.this.id
}

output "transit_gateway_arn" {
  description = "ARN of the Transit Gateway"
  value       = aws_ec2_transit_gateway.this.arn
}

output "ram_share_arn" {
  description = "ARN of the RAM resource share for the Transit Gateway"
  value       = aws_ram_resource_share.tgw.arn
}

output "dns_role_arn" {
  description = "ARN of the cross-account Route 53 record manager role"
  value       = aws_iam_role.route53_record_manager.arn
}

output "hosted_zone_id" {
  description = "Route 53 hosted zone ID passed through for downstream consumers"
  value       = var.hosted_zone_id
}
