# 04-logging

Sets up organization-wide CloudTrail and immutable log storage in the Log Archive account.

## Purpose

This layer configures two complementary components:

1. **CloudTrail (Management account):** An organization trail that captures API activity across every account in the AWS Organization. Multi-region and log-file validation are enabled by default.
2. **Log Archive S3 bucket (Log Archive account):** A dedicated, hardened bucket that receives all CloudTrail logs. The bucket enforces versioning, AES-256 encryption, and a full public-access block to ensure log immutability.

## Dual-Provider Pattern

The layer uses two AWS providers:

| Provider | Account | Resources |
|---|---|---|
| default (`aws`) | Management | `aws_cloudtrail` |
| `aws.log_archive` | Log Archive | S3 bucket, bucket policy, lifecycle rules |

The Log Archive provider assumes `OrganizationAccountAccessRole` in the target account.

## Lifecycle Policies

| Phase | Default | Description |
|---|---|---|
| Standard storage | 0 - 90 days | Objects remain in S3 Standard |
| Glacier IR | 90+ days | Transitioned to Glacier Instant Retrieval |
| Expiration | 365 days | Objects are permanently deleted |

All thresholds are configurable via `glacier_transition_days` and `log_retention_days`.

## Dependencies

- **01-organization:** Provides the organization ID and account IDs via `terraform_remote_state`.

## Usage

```bash
terraform init
terraform apply -var="log_archive_account_id=123456789012"
```

## Outputs

| Output | Description |
|---|---|
| `cloudtrail_arn` | ARN of the organization CloudTrail |
| `log_bucket_arn` | ARN of the CloudTrail log bucket |
| `log_bucket_name` | Name of the CloudTrail log bucket |
