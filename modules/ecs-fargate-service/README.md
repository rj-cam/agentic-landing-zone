# ECS Fargate Service Module

Deploys an ECS Fargate service with a task definition, CloudWatch log group, and security group that accepts traffic from the ALB.

## Usage

```hcl
module "ecs_service" {
  source = "../../modules/ecs-fargate-service"

  cluster_name          = "agentic-cluster"
  service_name          = "api-service"
  container_image       = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/api:latest"
  container_port        = 8080
  cpu                   = 512
  memory                = 1024
  desired_count         = 2
  subnet_ids            = module.vpc.private_subnet_ids
  vpc_id                = module.vpc.vpc_id
  target_group_arn      = module.alb.target_group_arn
  alb_security_group_id = module.alb.security_group_id
  environment           = "nonprod"
  aws_region            = "ap-southeast-1"

  tags = {
    Project = "agentic-landing-zone"
  }
}
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
