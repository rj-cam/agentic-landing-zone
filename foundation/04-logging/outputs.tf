output "cloudtrail_arn" {
  description = "ARN of the organization CloudTrail"
  value       = aws_cloudtrail.org_trail.arn
}

output "log_bucket_arn" {
  description = "ARN of the CloudTrail log bucket"
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "log_bucket_name" {
  description = "Name of the CloudTrail log bucket"
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}
