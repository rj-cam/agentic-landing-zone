###############################################################################
# Organization
###############################################################################

output "organization_id" {
  description = "The ID of the AWS Organization"
  value       = data.aws_organizations_organization.current.id
}

output "root_id" {
  description = "The ID of the organization root"
  value       = data.aws_organizations_organization.current.roots[0].id
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
# Account IDs — map
###############################################################################

output "account_ids" {
  description = "Map of account names to their IDs"
  value = {
    security        = aws_organizations_account.security.id
    log_archive     = aws_organizations_account.log_archive.id
    shared_services = aws_organizations_account.shared_services.id
    nonprod         = aws_organizations_account.nonprod.id
    prod            = aws_organizations_account.prod.id
  }
}

###############################################################################
# Account IDs — individual convenience outputs
###############################################################################

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

output "nonprod_account_id" {
  description = "Account ID of the Non-Prod account"
  value       = aws_organizations_account.nonprod.id
}

output "prod_account_id" {
  description = "Account ID of the Prod account"
  value       = aws_organizations_account.prod.id
}
