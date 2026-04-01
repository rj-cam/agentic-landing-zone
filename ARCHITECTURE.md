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
