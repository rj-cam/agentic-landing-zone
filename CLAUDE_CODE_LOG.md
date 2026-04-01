# Claude Code Development Log

> This file documents the AI-augmented development process for the AWS Landing Zone
> Reference Architecture. It is maintained manually during the build process.

## Session Log

| Date | Session | Changes Made | Key Decisions |
|------|---------|-------------|---------------|
| 2026-04-01 | Initial generation | Full IaC scaffold: 92 files, 3,820 lines. Modules (vpc, alb, ecs-fargate-service, scp-policy, dns-record), 6 foundation layers, 2 workload layers, CI/CD, scripts, docs | httpd over Go, single image with env-var selection, ARM64/Graviton, 9 ADRs |
| 2026-04-01 | Foundation provisioning | Applied all 6 foundation layers to AWS. Fixed issues discovered during apply. | Auto-wire account IDs from org outputs, import org as managed resource |
| 2026-04-01 | Architecture hardening | Replaced NAT Gateway with VPC Endpoints (ADR-008). Redesigned VPC to 5-tier, 3-AZ, dual-CIDR microsegmentation (ADR-009). | /24 + /21 CIDRs, NACLs per tier, compute_az_count variable |
| 2026-04-01 | Workload provisioning | Built ARM64 Docker image, pushed to ECR, provisioned both nonprod and prod. Fixed NACL and DNS issues. | S3 gateway endpoint needs open NACL rules, SSM endpoints deferred |

## Lessons Learned — AWS

### 1. IAM Identity Center cannot be enabled via CLI/API
The `CreateInstance` API returns `ValidationException` for the management account.
Must be enabled via AWS Console. This is an AWS limitation that breaks full
automation — document as a manual prerequisite.

### 2. RAM sharing requires both org service access AND enable-sharing
Two steps needed: (a) add `ram.amazonaws.com` to `aws_service_access_principals`
in the organization resource, and (b) run `aws ram enable-sharing-with-aws-organization`.
Without both, Transit Gateway RAM shares fail with `OperationNotPermittedException`.

### 3. SCP can block Terraform itself
The `protect-log-archive` SCP originally denied `s3:PutBucketPolicy` on the log
archive bucket. When Terraform tried to set the initial bucket policy in
`04-logging`, it was blocked by the SCP created in `02-scps`. Fix: remove
`s3:PutBucketPolicy` from the SCP deny list — the SCP should protect against
deletion, not block Terraform's initial setup.

### 4. S3 bucket names are globally unique
`landing-zone-cloudtrail-logs` was already taken by another AWS account.
Fix: append the account ID to make it unique (`landing-zone-cloudtrail-logs-894650615013`).

### 5. CIDR blocks must be properly aligned
A /21 CIDR must start on a 2048-IP boundary. `10.1.4.0/21` is invalid (AWS
expects `10.1.0.0/21`). Fix: use `10.1.8.0/21` as the secondary CIDR.

### 6. S3 Gateway Endpoint traffic uses public IPs in NACLs
S3 Gateway Endpoints route traffic via the VPC route table, but the destination
IPs are still **public S3 IPs** (e.g., 52.x.x.x). NACLs must allow outbound 443
to `0.0.0.0/0` and inbound ephemeral from `0.0.0.0/0` for the S3 gateway to work.
This is counter-intuitive — gateway endpoints avoid the internet but still use
public IP ranges at the network layer.

### 7. NACLs must allow DNS (UDP 53) explicitly
NACLs are stateless. Without explicit UDP 53 outbound to the VPC DNS resolver
(VPC CIDR base +2) and inbound ephemeral return, VPC endpoint private DNS
names cannot resolve. Tasks then fall back to public IPs and timeout.

### 8. DNS role trust policy must include the caller account
The `route53-record-manager` role was configured to trust only nonprod/prod
account roots. But Terraform runs as the management account user (which assumes
into workload accounts via provider). The DNS module's separate provider assumes
`route53-record-manager` directly from the management account — so the management
account root must also be in the trust policy.

### 9. Route 53 role needs more permissions than just ChangeResourceRecordSets
Terraform's Route 53 provider also calls `GetChange` (to wait for propagation)
and `ListResourceRecordSets` (to read existing records). Both must be in the
IAM policy. Iterating one permission at a time is slow — grant all read actions
upfront: `ListHostedZones`, `GetHostedZone`, `GetChange`, `ListResourceRecordSets`.

### 10. ECR IMMUTABLE tag policy + "latest" tag
ECR repository was created with `image_tag_mutability = "IMMUTABLE"`. This means
once `latest` is pushed, it cannot be overwritten. For a demo this is fine (one
push), but for CI/CD you must use unique tags (e.g., git SHA) — which the
deploy.yml workflow already does.

## Lessons Learned — Terraform

### 1. Provider blocks cannot reference data sources
Terraform evaluates provider blocks during init, before data sources run.
Account IDs for `assume_role` must come from variables, not `terraform_remote_state`.
The provisioning scripts solve this by extracting outputs from 01-organization
and passing them via `-var`.

### 2. terraform init must run before terraform output
If `.terraform/` is cleaned up between runs, `terraform output` fails with
"backend initialization required". All scripts that read outputs must run
`terraform init` first — even just to read state.

### 3. SCP policy type must be enabled before creating SCPs
AWS Organizations doesn't enable `SERVICE_CONTROL_POLICY` by default. The
`aws_organizations_organization` resource must include
`enabled_policy_types = ["SERVICE_CONTROL_POLICY"]`. We imported the existing
org as a managed resource to control this.

## Lessons Learned — VPC Endpoints + NACLs

### 1. Interface endpoints with private DNS resolve VPC-wide
Even though endpoints are placed in `app_endpoint` subnets (1 AZ), the private
DNS resolution works for all subnets in the VPC. The ENI IP is in the endpoint
subnet, but the DNS name resolves from anywhere in the VPC.

### 2. SSM endpoints are only needed with EC2
The `ssm`, `ssmmessages`, and `ec2messages` endpoints are for Systems Manager
agent communication. ECS Fargate doesn't use SSM. Removing these 3 endpoints
saves ~$22/month (nonprod) or ~$44/month (prod).

### 3. VPC Endpoint cost model
Interface endpoints: $7.30/month per AZ per endpoint. With 7 endpoints in 1 AZ
that's ~$51/month. The S3 gateway endpoint is free. Budget accordingly when
scaling to multiple AZs.

| Config | Endpoints | AZs | Monthly |
|--------|-----------|-----|---------|
| Nonprod (demo) | 7 | 1 | ~$51 |
| Prod (HA) | 7 | 2 | ~$102 |
| With SSM (+3) | 10 | 1 | ~$73 |
| With SSM (+3) | 10 | 2 | ~$146 |
