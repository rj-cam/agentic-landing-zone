# 02-scps - Service Control Policies

This Terraform layer creates and attaches six Service Control Policies (SCPs) to enforce guardrails across the AWS Organization.

## Dependencies

- **01-organization** - Provides OU IDs and account IDs via `terraform_remote_state`.

## SCPs

| SCP | Target | Purpose |
|-----|--------|---------|
| `region-restrict` | Root OU | Deny actions outside `ap-southeast-1` and `us-east-1`, excluding global services (IAM, Organizations, STS, CloudFront, Route 53, Support, Budgets, WAF, CloudWatch). |
| `deny-root` | Root OU | Deny all actions by the root user in any member account. |
| `require-s3-encryption` | Root OU | Deny S3 PutObject without server-side encryption (AES256/aws:kms) and deny non-HTTPS requests. |
| `require-ebs-encryption` | Root OU | Deny ec2:RunInstances when the EBS volume is not encrypted. |
| `protect-log-archive` | Log Archive Account | Deny deletion and policy changes on the centralized Log Archive S3 bucket. |
| `require-prod-tagging` | Prod OU | Deny resource creation without `Environment`, `Owner`, and `CostCenter` tags. |

## Variables

| Name | Description |
|------|-------------|
| `aws_region` | AWS region (default: `ap-southeast-1`) |
| `log_archive_account_id` | Log Archive account ID for the protect-log-archive SCP |
| `log_archive_bucket_arn` | Log Archive S3 bucket ARN |

## Usage

```bash
terraform init
terraform plan -var="log_archive_account_id=123456789012" -var="log_archive_bucket_arn=arn:aws:s3:::my-log-archive-bucket"
terraform apply
```
