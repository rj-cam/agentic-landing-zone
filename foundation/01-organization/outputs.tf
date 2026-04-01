###############################################################################
# Organization
###############################################################################

output "organization_id" {
  description = "The ID of the AWS Organization"
  value       = aws_organizations_organization.current.id
}

output "root_id" {
  description = "The ID of the organization root"
  value       = aws_organizations_organization.current.roots[0].id
}

###############################################################################
# Organizational Unit IDs
###############################################################################

output "ou_ids" {
  description = "Map of OU names to their IDs"
  value = {
    security        = aws_organizations_organizational_unit.security.id
    shared_services = aws_organizations_organizational_unit.shared_services.id
    workloads       = aws_organizations_organizational_unit.workloads.id
    nonprod         = aws_organizations_organizational_unit.nonprod.id
    prod            = aws_organizations_organizational_unit.prod.id
  }
}

###############################################################################
# Account IDs — infrastructure (static)
###############################################################################

output "account_ids" {
  description = "Map of all account names to their IDs (infra + workloads)"
  value = merge(
    {
      security        = aws_organizations_account.security.id
      log_archive     = aws_organizations_account.log_archive.id
      shared_services = aws_organizations_account.shared_services.id
    },
    { for k, v in aws_organizations_account.workload : k => v.id }
  )
}

output "security_account_id" {
  description = "Account ID of the Security account"
  value       = aws_organizations_account.security.id
}

output "log_archive_account_id" {
  description = "Account ID of the Log Archive account"
  value       = aws_organizations_account.log_archive.id
}

output "shared_services_account_id" {
  description = "Account ID of the Shared Services account"
  value       = aws_organizations_account.shared_services.id
}

###############################################################################
# Workload Account IDs (driven by environments.yaml)
###############################################################################

output "workload_account_ids" {
  description = "Map of workload environment names to account IDs"
  value       = { for k, v in aws_organizations_account.workload : k => v.id }
}

# Convenience outputs for backward compatibility with scripts
output "nonprod_account_id" {
  description = "Account ID of the Non-Prod account"
  value       = aws_organizations_account.workload["nonprod"].id
}

output "prod_account_id" {
  description = "Account ID of the Prod account"
  value       = aws_organizations_account.workload["prod"].id
}
