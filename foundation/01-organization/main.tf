###############################################################################
# Data source — reference existing AWS Organization (enabled in Phase 0)
###############################################################################

data "aws_organizations_organization" "current" {}

###############################################################################
# Organizational Units
###############################################################################

resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = data.aws_organizations_organization.current.roots[0].id
}

resource "aws_organizations_organizational_unit" "shared_services" {
  name      = "Shared Services"
  parent_id = data.aws_organizations_organization.current.roots[0].id
}

resource "aws_organizations_organizational_unit" "workloads" {
  name      = "Workloads"
  parent_id = data.aws_organizations_organization.current.roots[0].id
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
# Member Accounts
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

resource "aws_organizations_account" "nonprod" {
  name      = "Non-Prod"
  email     = var.nonprod_account_email
  role_name = "OrganizationAccountAccessRole"
  parent_id = aws_organizations_organizational_unit.nonprod.id

  lifecycle {
    ignore_changes = [role_name]
  }
}

resource "aws_organizations_account" "prod" {
  name      = "Prod"
  email     = var.prod_account_email
  role_name = "OrganizationAccountAccessRole"
  parent_id = aws_organizations_organizational_unit.prod.id

  lifecycle {
    ignore_changes = [role_name]
  }
}
