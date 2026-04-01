# 01-organization

Creates the AWS Organizations hierarchy and member accounts for the landing zone.

## Purpose

This layer provisions the organizational unit (OU) structure and member accounts under an existing AWS Organization (enabled during Phase 0 bootstrap). The hierarchy is:

```
Root
├── Security OU
│   ├── Security account
│   └── Log Archive account
├── Shared Services OU
│   └── Shared Services account
└── Workloads OU
    ├── Non-Prod OU
    │   └── Non-Prod account
    └── Prod OU
        └── Prod account
```

## Dependencies

- **Phase 0 (00-bootstrap):** The S3 backend bucket, DynamoDB lock table, and AWS Organizations must already exist before applying this layer.

## Usage

```bash
terraform init
terraform apply
```

## Outputs

| Output | Description |
|---|---|
| `organization_id` | AWS Organization ID |
| `root_id` | Organization root ID |
| `ou_ids` | Map of OU names to IDs |
| `account_ids` | Map of account names to account IDs |
| `security_account_id` | Security account ID |
| `log_archive_account_id` | Log Archive account ID |
| `shared_services_account_id` | Shared Services account ID |
| `nonprod_account_id` | Non-Prod account ID |
| `prod_account_id` | Prod account ID |

These outputs are consumed by downstream layers (SCPs, CloudTrail, GuardDuty, IAM Identity Center, networking, etc.) via `terraform_remote_state` data sources.
