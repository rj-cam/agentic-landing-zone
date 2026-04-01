###############################################################################
# SCP Policy IDs
###############################################################################

output "region_restrict_policy_id" {
  description = "Policy ID of the region-restrict SCP"
  value       = module.region_restrict.policy_id
}

output "deny_root_policy_id" {
  description = "Policy ID of the deny-root SCP"
  value       = module.deny_root.policy_id
}

output "require_s3_encryption_policy_id" {
  description = "Policy ID of the require-s3-encryption SCP"
  value       = module.require_s3_encryption.policy_id
}

output "require_ebs_encryption_policy_id" {
  description = "Policy ID of the require-ebs-encryption SCP"
  value       = module.require_ebs_encryption.policy_id
}

output "protect_log_archive_policy_id" {
  description = "Policy ID of the protect-log-archive SCP"
  value       = module.protect_log_archive.policy_id
}

output "require_prod_tagging_policy_id" {
  description = "Policy ID of the require-prod-tagging SCP"
  value       = module.require_prod_tagging.policy_id
}
