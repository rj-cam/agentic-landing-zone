# Phase 0 — Bootstrap (Manual)

> **These are manual prerequisites that must be completed before running any
> Terraform.** Some cannot be automated via CLI or IaC and require AWS Console
> access.

## Checklist

Complete all items before running `provision-foundation.sh`:

### AWS Console steps (cannot be automated)

- [ ] **Enable IAM Identity Center** — Go to AWS Console → IAM Identity Center
  (in `ap-southeast-1`) → Click "Enable" → Choose "Enable with AWS Organizations".
  This is required before `foundation/03-identity-center` can apply.

### CLI / already completed

- [x] **AWS Organizations** — Enabled (all features) on the management account
- [x] **S3 State Bucket** — `rj-landing-zone-tfstate` (ap-southeast-1, versioned,
  all public access blocked)
- [x] **DynamoDB Lock Table** — `rj-landing-zone-tflock` (PAY_PER_REQUEST)
- [x] **Billing Budget** — $50/month with 80% threshold alert
- [x] **Root MFA** — Enabled on the management account
- [x] **Route 53 Hosted Zone** — `therj.link` (Zone ID: `Z02874271LXAPI4H9WD4L`)

### Automated by Terraform (no manual action needed)

The following were previously listed as manual but are now managed by Terraform:

- **SCP policy type** — Enabled automatically by `foundation/01-organization`
  (via `aws_organizations_organization` resource with `enabled_policy_types`)
- **Organization-wide CloudTrail** — Created by `foundation/04-logging`
  (do NOT create manually — Terraform manages the `org-trail` resource)
- **SSO service access** — Enabled automatically by `foundation/01-organization`
  (via `aws_service_access_principals`)

## Why can't IAM Identity Center be automated?

AWS requires the initial enablement of IAM Identity Center to be done through
the Console for the management account. The `CreateInstance` API returns
`ValidationException: Organization management account is not allowed to perform
the operation` when called via CLI/SDK. Once enabled in the Console, all
subsequent configuration (permission sets, users, groups, account assignments)
is fully managed by Terraform in `foundation/03-identity-center`.

## Reference scripts

- **bootstrap.sh** — Reference bash script documenting the CLI commands used.
- **bootstrap.bat** — Windows batch equivalent.
- **BOOTSTRAP_LOG.md** — Log of what was created and by whom.
