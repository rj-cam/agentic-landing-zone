output "fqdn" {
  description = "The FQDN of the created record"
  value       = aws_route53_record.this.fqdn
}
