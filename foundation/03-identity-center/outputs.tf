output "identity_center_arn" {
  description = "ARN of the IAM Identity Center instance"
  value       = local.sso_instance_arn
}

output "permission_set_arns" {
  description = "Map of permission set names to their ARNs"
  value = {
    AdministratorAccess = aws_ssoadmin_permission_set.admin.arn
    DeveloperAccess     = aws_ssoadmin_permission_set.developer.arn
    ReadOnlyAccess      = aws_ssoadmin_permission_set.readonly.arn
  }
}
