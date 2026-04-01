output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.httpd.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.httpd.arn
}

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions IAM role for ECR push"
  value       = aws_iam_role.github_actions_ecr.arn
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = aws_iam_openid_connect_provider.github.arn
}
