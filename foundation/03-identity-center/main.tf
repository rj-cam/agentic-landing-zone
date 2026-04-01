###############################################################################
# Remote State — Organization
###############################################################################

data "terraform_remote_state" "organization" {
  backend = "s3"

  config = {
    bucket = "rj-landing-zone-tfstate"
    key    = "foundation/01-organization/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

###############################################################################
# Identity Center Instance
###############################################################################

data "aws_ssoadmin_instances" "this" {}

locals {
  sso_instance_arn  = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  account_ids = data.terraform_remote_state.organization.outputs.account_ids

  all_account_ids = values(local.account_ids)
}

###############################################################################
# Permission Sets
###############################################################################

resource "aws_ssoadmin_permission_set" "admin" {
  name             = "AdministratorAccess"
  instance_arn     = local.sso_instance_arn
  session_duration = "PT4H"
  description      = "Full administrator access"
}

resource "aws_ssoadmin_permission_set" "developer" {
  name             = "DeveloperAccess"
  instance_arn     = local.sso_instance_arn
  session_duration = "PT4H"
  description      = "Power-user access for developers"
}

resource "aws_ssoadmin_permission_set" "readonly" {
  name             = "ReadOnlyAccess"
  instance_arn     = local.sso_instance_arn
  session_duration = "PT4H"
  description      = "Read-only access for auditing and review"
}

###############################################################################
# Managed Policy Attachments
###############################################################################

resource "aws_ssoadmin_managed_policy_attachment" "admin" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_ssoadmin_managed_policy_attachment" "developer" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.developer.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_ssoadmin_managed_policy_attachment" "readonly" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.readonly.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

###############################################################################
# Local Admin User
###############################################################################

resource "aws_identitystore_user" "admin" {
  identity_store_id = local.identity_store_id
  user_name         = var.admin_user_name
  display_name      = var.admin_user_name

  name {
    given_name  = var.admin_given_name
    family_name = var.admin_family_name
  }

  emails {
    value   = var.admin_user_email
    primary = true
  }
}

###############################################################################
# Admins Group
###############################################################################

resource "aws_identitystore_group" "admins" {
  identity_store_id = local.identity_store_id
  display_name      = "Administrators"
  description       = "Full administrators group"
}

resource "aws_identitystore_group_membership" "admin" {
  identity_store_id = local.identity_store_id
  member_id         = aws_identitystore_user.admin.user_id
  group_id          = aws_identitystore_group.admins.group_id
}

###############################################################################
# Account Assignments — AdministratorAccess to Admins group (all accounts)
###############################################################################

resource "aws_ssoadmin_account_assignment" "admin_all" {
  for_each = toset(local.all_account_ids)

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
  principal_id       = aws_identitystore_group.admins.group_id
  principal_type     = "GROUP"
  target_id          = each.value
  target_type        = "AWS_ACCOUNT"
}

###############################################################################
# Account Assignments — ReadOnlyAccess to Admins group (all accounts)
###############################################################################

resource "aws_ssoadmin_account_assignment" "readonly_all" {
  for_each = toset(local.all_account_ids)

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.readonly.arn
  principal_id       = aws_identitystore_group.admins.group_id
  principal_type     = "GROUP"
  target_id          = each.value
  target_type        = "AWS_ACCOUNT"
}

###############################################################################
# Account Assignments — DeveloperAccess to Admins group (nonprod only)
###############################################################################

resource "aws_ssoadmin_account_assignment" "developer_nonprod" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.developer.arn
  principal_id       = aws_identitystore_group.admins.group_id
  principal_type     = "GROUP"
  target_id          = local.account_ids["nonprod"]
  target_type        = "AWS_ACCOUNT"
}
