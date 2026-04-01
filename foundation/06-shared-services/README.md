# 06 - Shared Services

This layer provisions shared infrastructure in the Shared Services account.

## What it creates

- **ECR Repository** (`landing-zone/httpd`) - Shared container image registry with immutable tags, scan-on-push enabled, and lifecycle policies to keep the last 10 tagged images and expire untagged images after 7 days.
- **Cross-Account ECR Pull Policy** - Grants the Non-Production and Production accounts read-only access to pull images from ECR.
- **GitHub OIDC Provider** - Enables keyless authentication from GitHub Actions using OpenID Connect, eliminating the need for long-lived AWS credentials.
- **GitHub Actions ECR Role** - IAM role assumable by GitHub Actions workflows in the `rj-cam/agentic-landing-zone` repository, scoped to push and pull images to the ECR repository.

## Dependencies

| Layer | Purpose |
|-------|---------|
| 00-bootstrap | S3 backend for state storage |
| 01-organization | Organization remote state (account IDs) |

## Usage

```bash
terraform init
terraform plan -var="shared_services_account_id=XXXXXXXXXXXX" \
               -var="nonprod_account_id=XXXXXXXXXXXX" \
               -var="prod_account_id=XXXXXXXXXXXX"
terraform apply
```
