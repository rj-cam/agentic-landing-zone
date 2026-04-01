# Phase 0 -- Bootstrap (Manual)

> **WARNING: DO NOT re-run any scripts in this directory.**
> They exist for reference only. All Phase 0 resources were created manually
> before any Infrastructure-as-Code was in place.

## What was done

Phase 0 established the foundational AWS resources required before Terraform
can manage infrastructure. These were provisioned by hand through the AWS
Console and CLI.

## Resources created

| Resource | Details |
|----------|---------|
| AWS Organizations | Enabled on the management account |
| S3 State Bucket | `rj-landing-zone-tfstate` (ap-southeast-1, versioning enabled, all public access blocked) |
| DynamoDB Lock Table | `rj-landing-zone-tflock` (PAY_PER_REQUEST billing mode) |
| CloudTrail | `org-trail` -- organization-wide trail |
| Billing Budget | $50/month with alert at 80% threshold |
| Root MFA | Enabled on the root account |
| Route 53 Hosted Zone | `therj.link` (Zone ID: `Z02874271LXAPI4H9WD4L`) |

## Files in this directory

- **bootstrap.sh** -- Reference bash script documenting the CLI commands used.
- **bootstrap.bat** -- Windows batch equivalent of the above.
- **BOOTSTRAP_LOG.md** -- Log of what was created and by whom.
