# Architecture Decision Records

This document captures the key architectural decisions made for the Agentic Landing Zone reference implementation. Each ADR explains the context, decision, consequences, and how the pattern maps to Azure for teams evaluating multi-cloud strategies.

---

## ADR-001: Cloud-Native Architecture, Cloud-Agnostic Deployment

**Status:** Accepted
**Context:** Need to build workloads that are portable. Cloud is an implementation decision driven by business value (cost, regulation, data residency), not a default technology preference.
**Decision:** Architect using cloud-native patterns (containers, IaC, stateless services, policy-as-code). The deployment target is a business decision.
**Consequences:** Workloads use containers (httpd on Fargate), IaC (Terraform), and standard protocols. Switching clouds requires re-implementing infrastructure layers but not application logic.
**AWS ↔ Azure equivalent:** Azure Container Apps / AKS, Bicep/Terraform, Azure Policy.

---

## ADR-002: ECS Fargate over EKS for Sample Workload

**Status:** Accepted
**Context:** Need container compute for the sample workload. EKS is the production recommendation but adds significant cost ($73/month for control plane) and operational complexity.
**Decision:** Use ECS Fargate with ARM64/Graviton for the reference implementation. Smallest task size (256 CPU / 512 MiB). Document EKS as the production recommendation.
**Consequences:** Lower cost (<$30/cycle), simpler operations, no cluster management. Give up Kubernetes ecosystem, CNCF tooling, multi-cloud container orchestration portability.
**AWS ↔ Azure equivalent:** Azure Container Instances (similar simplicity) or AKS (similar to EKS).

---

## ADR-003: Multi-Account Strategy over Single Account

**Status:** Accepted
**Context:** Enterprise workloads need blast radius isolation, separate billing, independent IAM boundaries, and regulatory separation.
**Decision:** Five accounts — Management, Security/Audit, Log Archive, Shared Services, and two Workload accounts (Non-Prod, Prod) — organized in OUs under AWS Organizations.
**Consequences:** Stronger security boundaries, independent billing, SCP-based governance. Adds cross-account IAM complexity and operational overhead for small teams.
**AWS ↔ Azure equivalent:** Azure Management Groups + Subscriptions (1:1 mapping to OUs + Accounts).

---

## ADR-004: Hub-and-Spoke Networking via Transit Gateway

**Status:** Accepted
**Context:** Workload VPCs need connectivity to shared services and potentially to each other, with centralized routing control.
**Decision:** Transit Gateway in Shared Services account, shared via RAM to the organization. Each workload VPC attaches to TGW. Single route table for simplicity.
**Consequences:** Centralized routing, scalable to hundreds of VPCs, enables future inspection/firewall insertion. TGW has per-attachment and per-GB costs. Single route table simplifies but limits segmentation.
**AWS ↔ Azure equivalent:** Azure Virtual WAN or VNet Peering with hub VNet.

---

## ADR-005: SCPs for Preventive Controls over Detective Controls

**Status:** Accepted
**Context:** Need to enforce governance — region restrictions, encryption requirements, tagging, root account lockout.
**Decision:** Use Service Control Policies as the primary guardrail mechanism. Prevent non-compliant resources from being created rather than detecting them after creation.
**Consequences:** Immediate enforcement, no remediation lag, no non-compliant resources exist. SCPs are blunt instruments — they affect all principals including automation. AWS Config Rules documented as complementary detective layer.
**AWS ↔ Azure equivalent:** Azure Policy with Deny effect (direct equivalent).

---

## ADR-006: GitHub Actions OIDC over Long-Lived IAM Access Keys

**Status:** Accepted
**Context:** CI/CD pipelines need AWS credentials. Long-lived access keys are a security risk (rotation burden, potential exposure in logs/repos).
**Decision:** Use GitHub Actions OIDC federation. IAM roles trust the GitHub OIDC provider with conditions scoped to specific repos. No secrets to store or rotate.
**Consequences:** Short-lived credentials (~1h), no secret rotation, auditable via CloudTrail, scoped to specific repos. Requires OIDC provider setup in each account. Vendor coupling to GitHub Actions trust model.
**AWS ↔ Azure equivalent:** Same pattern — GitHub OIDC works identically with Azure Workload Identity Federation.

---

## ADR-007: Terraform with S3 Backend over AWS CloudFormation

**Status:** Accepted
**Context:** Need an IaC tool for the landing zone. CloudFormation is AWS-native but vendor-locked.
**Decision:** Use Terraform (open-source, HashiCorp BSL) with S3+DynamoDB backend. Layered state files with remote state references between layers.
**Consequences:** Multi-cloud portability, larger ecosystem, HCL is more expressive than YAML/JSON. Give up CloudFormation's tight AWS integration (drift detection, stack sets, change sets with CloudFormation-native resources). State management is an operational responsibility.
**AWS ↔ Azure equivalent:** Terraform with Azure Storage Account backend (same tool, different backend).

---

## ADR-008: VPC Endpoints over NAT Gateway

**Status:** Accepted

**Context:** Private subnets need access to AWS services (ECR for image pulls, CloudWatch for logs, ECS control plane). The conventional approach is a NAT Gateway (~$32/month + $0.045/GB data processing), which provides general internet access. However, our Fargate workloads only communicate with AWS services — they have no need for outbound internet access. For EC2 workloads, NAT Gateways are commonly used for OS patching via internet package repositories (yum, apt).

**Decision:** Replace NAT Gateway with VPC Endpoints for all required AWS service connectivity:

| Use Case | VPC Endpoint | Type | Cost |
|----------|-------------|------|------|
| ECR image pull (API) | `com.amazonaws.{region}.ecr.api` | Interface | ~$7.30/mo |
| ECR image pull (Docker) | `com.amazonaws.{region}.ecr.dkr` | Interface | ~$7.30/mo |
| ECR image layers | `com.amazonaws.{region}.s3` | Gateway | Free |
| Container logs | `com.amazonaws.{region}.logs` | Interface | ~$7.30/mo |
| ECS control plane | `com.amazonaws.{region}.ecs` | Interface | ~$7.30/mo |
| ECS agent comms | `com.amazonaws.{region}.ecs-agent` | Interface | ~$7.30/mo |
| ECS telemetry | `com.amazonaws.{region}.ecs-telemetry` | Interface | ~$7.30/mo |
| Role assumption (cross-account) | `com.amazonaws.{region}.sts` | Interface | ~$7.30/mo |
| EC2 patching (replaces yum/apt over NAT) | `com.amazonaws.{region}.ssm` | Interface | ~$7.30/mo |
| SSM session channels | `com.amazonaws.{region}.ssmmessages` | Interface | ~$7.30/mo |
| SSM EC2 messages | `com.amazonaws.{region}.ec2messages` | Interface | ~$7.30/mo |

**Consequences:**

- *Security improvement:* Traffic to AWS services stays on the AWS backbone via AWS PrivateLink — never traverses the public internet. Reduces attack surface.
- *No outbound internet:* Workloads in private subnets cannot reach the public internet at all. This is a feature, not a limitation — it enforces the principle of least connectivity.
- *EC2 patching model change:* Instead of patching via internet repos through NAT, use AWS Systems Manager Patch Manager via SSM VPC Endpoints. This is the AWS-recommended approach for private subnets and provides auditable, policy-driven patching.
- *Cost:* Interface endpoints cost ~$7.30/month each (2 AZs × $0.01/hr). With 10 interface endpoints that's ~$73/month — higher than a single NAT Gateway's base cost, but eliminates the per-GB data processing charge ($0.045/GB) which can be significant at scale. The S3 Gateway endpoint is free.
- *No external API access:* If a workload later needs to call external APIs (SaaS, third-party services), a NAT Gateway or proxy would need to be added back for those specific routes.

**AWS ↔ Azure equivalent:** Azure Private Link endpoints serve the same purpose — keeping traffic to Azure services on the Microsoft backbone without requiring a NAT Gateway or Azure Firewall for service access.

---

## ADR-009: VPC Microsegmentation — 5-Tier Subnet Architecture

**Status:** Accepted

**Context:** A flat VPC with only "public" and "private" subnets provides no network-level isolation between application tiers. In regulated environments (banking, finance), compliance frameworks require defense-in-depth with network segmentation so that a compromise in the web tier cannot directly reach the data tier. The design is based on a production-proven subnet layout used in banking deployments.

**Decision:** Implement a 5-tier subnet architecture across 3 AZs using dual VPC CIDRs:

```
CIDR 1 (/24) — Infrastructure          CIDR 2 (/21) — Workloads
┌──────────────────────────┐            ┌──────────────────────────┐
│ TGW         /28 × 3 AZs │            │ App Endpoint /27 × 3 AZs │
│ Web ALB     /27 × 3 AZs │            │ Data         /27 × 3 AZs │
│ Web NLB     /27 × 3 AZs │            │ App Compute  /23 × 3 AZs │
└──────────────────────────┘            └──────────────────────────┘
```

| Tier | Subnets | Purpose | NACL policy |
|------|---------|---------|-------------|
| **TGW** | /28 × 3 | Transit Gateway ENIs only | Allow 10.0.0.0/8 (cross-VPC) |
| **Web ALB** | /27 × 3 (public) | Internet-facing ALB | Inbound 80/443 from internet; outbound to app compute only |
| **Web NLB** | /27 × 3 (reserved) | Future NLB | Permissive (reserved) |
| **App Endpoint** | /27 × 3 | VPC endpoints, EFS mounts, bastion | Inbound 443 from app compute; no direct internet |
| **App Compute** | /23 × 3 | ECS/EKS tasks | Inbound 80 from web; outbound 3306/5432 to data, 443 to endpoints |
| **Data** | /27 × 3 (reserved) | RDS, ElastiCache | Inbound 3306/5432 from app compute only |

Traffic flow enforced by NACLs: **Internet → Web → App → Data** (no reverse initiation, no tier bypass).

The `/23` app compute subnets (510 IPs per AZ) accommodate EKS VPC CNI pod networking at scale without requiring prefix delegation. VPC endpoints are placed in dedicated `/27` app endpoint subnets to avoid IP contention with compute workloads.

A `compute_az_count` variable controls how many AZs run Fargate tasks and VPC endpoints (1 for nonprod cost savings, 2+ for prod HA). All 3 AZs of subnets are always created for future scaling.

**Production considerations not implemented in reference:**
- Gateway Load Balancer (GWLB) subnets for inline traffic inspection via network appliances
- AWS Network Firewall for east-west traffic filtering between tiers
- VPC Flow Logs to S3 in Log Archive account for network forensics

**Consequences:**
- *Defense-in-depth:* Network-level isolation between tiers via NACLs + security groups. A compromised web-tier container cannot reach the database directly.
- *Compliance alignment:* Meets network segmentation requirements in PCI-DSS, MAS TRM, and SOC 2 control frameworks.
- *Dual CIDR:* Each VPC uses /24 + /21 = ~2,300 IPs. With 10.0.0.0/8 address space, supports ~250 workload accounts before exhaustion.
- *Subnet sprawl:* 18 subnets per VPC (6 tiers × 3 AZs). Manageable via Terraform modules but more complex than a 2-tier design.
- *NACL statefulness:* NACLs are stateless — ephemeral port ranges must be explicitly allowed for return traffic. This adds rule complexity but is unavoidable for tier-level enforcement.

**AWS ↔ Azure equivalent:** Azure Network Security Groups (NSGs) attached to subnets serve the same tier-isolation role. Azure Application Security Groups (ASGs) provide the equivalent of security-group-based rules. Azure VNet subnets with NSGs + Azure Firewall for east-west inspection.

---

## AWS ↔ Azure Equivalence Table

| Capability | AWS (this implementation) | Azure Equivalent |
|------------|--------------------------|------------------|
| Multi-account governance | Organizations + OUs | Management Groups |
| Preventive guardrails | Service Control Policies | Azure Policy (Deny effect) |
| Account/subscription vending | Organizations API | Subscription vending (Bicep/Terraform) |
| Centralised identity | IAM Identity Center | Entra ID (Azure AD) |
| Hub-and-spoke networking | Transit Gateway | Azure Virtual WAN / VNet peering |
| Container registry | ECR | Azure Container Registry |
| Container compute | ECS Fargate | Azure Container Instances / AKS |
| ARM64 compute | Graviton (ARM64) | Ampere Altra (ARM64) VMs |
| Load balancing | ALB | Azure Application Gateway |
| DNS | Route 53 | Azure DNS |
| IaC state | S3 + DynamoDB | Azure Storage Account + Blob lease |
| CI/CD identity | GitHub Actions OIDC | GitHub Actions OIDC (identical) |
| Logging | CloudTrail | Azure Activity Log |
| Security posture | Security Hub + GuardDuty | Defender for Cloud + Sentinel |
| Policy-as-code | SCPs + Config Rules | Azure Policy + Blueprints |
