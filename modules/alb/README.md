# ALB Module

Provisions an Application Load Balancer with a default target group and security group for serving HTTPS/HTTP traffic to backend containers.

## Usage

```hcl
module "alb" {
  source = "../../modules/alb"

  name              = "agentic-alb"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.public_subnet_ids
  health_check_path = "/health"
  container_port    = 8080
  environment       = "nonprod"

  tags = {
    Project = "agentic-landing-zone"
  }
}
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
