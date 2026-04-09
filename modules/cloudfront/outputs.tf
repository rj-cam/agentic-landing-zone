output "distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.id
}

output "distribution_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.domain_name
}

output "distribution_hosted_zone_id" {
  description = "Route 53 zone ID for the CloudFront distribution (always Z2FDTNDATAQYW2)"
  value       = aws_cloudfront_distribution.this.hosted_zone_id
}
