###############################################################################
# Data source — reference existing AWS Organization (enabled in Phase 0)
###############################################################################

###############################################################################
# AWS Organization — imported from Phase 0, now Terraform-managed
###############################################################################

resource "aws_organizations_organization" "current" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "ram.amazonaws.com",
    "sso.amazonaws.com",
  ]
  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY",
  ]
  feature_set = "ALL"
}

###############################################################################
# Organizational Units
###############################################################################

resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = aws_organizations_organization.current.roots[0].id
}

resource "aws_organizations_organizational_unit" "shared_services" {
  name      = "Shared Services"
  parent_id = aws_organizations_organization.current.roots[0].id
}

resource "aws_organizations_organizational_unit" "workloads" {
  name      = "Workloads"
  parent_id = aws_organizations_organization.current.roots[0].id
}

resource "aws_organizations_organizational_unit" "nonprod" {
  name      = "Non-Prod"
  parent_id = aws_organizations_organizational_unit.workloads.id
}

resource "aws_organizations_organizational_unit" "prod" {
  name      = "Prod"
  parent_id = aws_organizations_organizational_unit.workloads.id
}

###############################################################################
# Environment definitions from YAML
###############################################################################

locals {
  environments = yamldecode(file("${path.module}/../../environments.yaml"))["environments"]

  ou_map = {
    nonprod = aws_organizations_organizational_unit.nonprod.id
    prod    = aws_organizations_organizational_unit.prod.id
  }
}

###############################################################################
# Infrastructure Accounts (static)
###############################################################################

resource "aws_organizations_account" "security" {
  name      = "Security"
  email     = var.security_account_email
  role_name = "OrganizationAccountAccessRole"
  parent_id = aws_organizations_organizational_unit.security.id

  lifecycle {
    ignore_changes = [role_name]
  }
}

resource "aws_organizations_account" "log_archive" {
  name      = "Log Archive"
  email     = var.log_archive_account_email
  role_name = "OrganizationAccountAccessRole"
  parent_id = aws_organizations_organizational_unit.security.id

  lifecycle {
    ignore_changes = [role_name]
  }
}

resource "aws_organizations_account" "shared_services" {
  name      = "Shared Services"
  email     = var.shared_services_account_email
  role_name = "OrganizationAccountAccessRole"
  parent_id = aws_organizations_organizational_unit.shared_services.id

  lifecycle {
    ignore_changes = [role_name]
  }
}

###############################################################################
# Workload Accounts (driven by environments.yaml)
###############################################################################

resource "aws_organizations_account" "workload" {
  for_each = local.environments

  name      = each.value.account_name
  email     = each.value.account_email
  role_name = "OrganizationAccountAccessRole"
  parent_id = local.ou_map[each.value.ou]

  lifecycle {
    ignore_changes = [role_name]
  }
}
