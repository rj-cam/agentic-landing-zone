# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Multi-account AWS Landing Zone reference implementation using Terraform. Provisions 5 accounts (Management, Security, Log Archive, Shared Services, Non-Prod, Prod) with SCPs, Transit Gateway hub-and-spoke networking, IAM Identity Center, centralised logging, CloudFront with VPC Origins, and ECS Fargate ARM64 workloads. Region: `ap-southeast-1` (CloudFront certs in `us-east-1`).

## Commands

### Terraform Operations (per-layer)

```bash
# Each foundation/workload layer is an independent Terraform root module
cd foundation/01-organization  # or any layer
terraform init
terraform plan
terraform apply

# Validate a module
terraform validate
terraform fmt -check
```

### Provision / Teardown (full stack)

```bash
./scripts/provision-foundation.sh    # Layers 01-06 in order, auto-extracts account IDs
./scripts/provision-workloads.sh     # All workload directories
./scripts/teardown-workloads.sh      # Destroy workloads in reverse order
```

Teardown order matters: workloads first, then foundation layers 06 -> 01. Never destroy `01-organization` before other layers.

### Add a New Environment

1. Add entry to `environments.yaml`
2. Run `scripts/vend-environment.sh <name>` (generates the workload directory)
3. Run `provision-foundation.sh` then `provision-workloads.sh`

### Generate Module Docs

```bash
terraform-docs . > README.md  # Uses .terraform-docs.yml config
```

## Architecture

### Layered State Design

Foundation and workload layers use **separate Terraform state files** with `terraform_remote_state` data sources for cross-layer references. State is in S3 (`rj-landing-zone-tfstate`) with DynamoDB locking (`rj-landing-zone-tflock`).

**Foundation layers (must be applied in order):**
1. `01-organization` — AWS Organizations, OUs, member accounts (outputs account IDs used by all downstream layers)
2. `02-scps` — 6 Service Control Policies (region-restrict, deny-root, encryption, tagging)
3. `03-identity-center` — IAM Identity Center permission sets and assignments
4. `04-logging` — CloudTrail org trail + S3 log archive bucket
5. `05-networking` — VPCs (5-tier microsegmentation), Transit Gateway, Route 53 DNS role
6. `06-shared-services` — ECR repository, GitHub OIDC provider

**Workload layers** (`workloads/01-nonprod`, `workloads/02-prod`) are thin wrappers (~30 lines in `main.tf`) that call `modules/workload` with environment-specific values.

### Module Composition

`modules/workload` is the DRY template (ADR-011) that composes all sub-modules:
- `modules/vpc` — 5-tier VPC with dual CIDRs, 18 subnets (TGW/Web ALB/Web NLB/App Endpoint/App Compute/Data)
- `modules/alb` — Internal ALB with TLS 1.3, HTTP->HTTPS redirect
- `modules/cloudfront` — CloudFront distribution with VPC Origins to internal ALB (ADR-012)
- `modules/ecs-fargate-service` — ECS Fargate ARM64 service + task definition
- `modules/dns-record` — Cross-account Route 53 alias record (points to CloudFront)
- `modules/scp-policy` — Reusable SCP + OU attachment
- Security hardening (OIDC, default EBS encryption) is inline in `modules/workload`

Sub-modules use relative `source` paths (`../vpc`, `../alb`, etc.).

### Cross-Account Pattern

All providers use `assume_role` with `OrganizationAccountAccessRole` to operate in member accounts from the management account. The `aws.dns` aliased provider assumes a dedicated DNS role for Route 53 records. The `aws.us_east_1` aliased provider operates in the workload account's `us-east-1` region for CloudFront ACM certificates.

### CIDR Addressing Scheme

Each environment uses `10.{cidr_index}.0.0/24` (infra) + `10.{cidr_index}.8.0/21` (workloads), defined in `environments.yaml`. The `cidr_index` (1=nonprod, 2=prod) prevents overlap.

### CI/CD

`.github/workflows/deploy.yml`: Build ARM64 image -> Push to ECR (Shared Services) -> Deploy Non-Prod -> Manual approval -> Deploy Prod. All AWS auth via GitHub OIDC — no long-lived keys.
