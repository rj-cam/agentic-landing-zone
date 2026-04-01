# 05-networking

This layer provisions the core networking and DNS resources for the landing zone.

## What it creates

### Transit Gateway (Shared Services account)
- An AWS Transit Gateway configured as the hub for hub-and-spoke network connectivity.
- A RAM resource share that makes the Transit Gateway available to all accounts in the Organization.

### DNS cross-account role (Management account)
- An IAM role (`route53-record-manager`) that workload accounts (non-prod and prod) can assume to manage Route 53 records in the management account's hosted zone.

## Dependencies

| Layer | Purpose |
|-------|---------|
| 00-bootstrap | S3 backend and DynamoDB lock table |
| 01-organization | Organization ID used for RAM sharing |

## Usage

```bash
terraform init
terraform plan -var-file="../../environments/networking.tfvars"
terraform apply -var-file="../../environments/networking.tfvars"
```
