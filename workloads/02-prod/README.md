# 02-prod — Production Workload

This layer provisions the production workload environment.

## Resources

- **VPC** — `10.2.0.0/16` with public and private subnets across two AZs
- **ALB** — Application Load Balancer in public subnets
- **ECS Fargate (ARM64)** — `sample-prod` cluster with 2 tasks (high availability)
- **DNS** — Route 53 record `prod.therj.link` pointing to the ALB

## Dependencies

| Layer | Purpose |
|-------|---------|
| `foundation/01-organization` | AWS Organization and account IDs |
| `foundation/05-networking` | Hosted zone for DNS |
| `foundation/06-shared-services` | ECR repository URL |
