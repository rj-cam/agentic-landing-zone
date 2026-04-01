# Non-Production Workload

This layer provisions the non-production workload environment, including networking, compute, and DNS resources.

## Resources

- **VPC** - `10.1.0.0/16` with 2 public and 2 private subnets across `ap-southeast-1a` and `ap-southeast-1b`
- **ALB** - Application Load Balancer in public subnets
- **ECS Fargate (ARM64)** - 1 task running `sample-service` (256 CPU / 512 MB memory)
- **DNS** - Route 53 alias record `nonprod.therj.link` pointing to the ALB

## Dependencies

This layer depends on the following foundation layers:

| Layer | Remote State Key | Purpose |
|-------|-----------------|---------|
| 01 - Organization | `foundation/01-organization` | Account structure |
| 05 - Networking | `foundation/05-networking` | Transit Gateway, hosted zone, DNS role |
| 06 - Shared Services | `foundation/06-shared-services` | ECR repository URL |

## Usage

```bash
terraform init
terraform plan -var="nonprod_account_id=123456789012"
terraform apply -var="nonprod_account_id=123456789012"
```
