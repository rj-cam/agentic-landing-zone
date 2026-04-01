# VPC Module

Creates a multi-AZ VPC with public and private subnets, NAT gateways, and a Transit Gateway attachment for hybrid connectivity.

## Usage

```hcl
module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr             = "10.1.0.0/16"
  public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs = ["10.1.10.0/24", "10.1.11.0/24"]
  availability_zones   = ["ap-southeast-1a", "ap-southeast-1b"]
  transit_gateway_id   = "tgw-0abc123def456789"
  environment          = "nonprod"

  tags = {
    Project = "agentic-landing-zone"
  }
}
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
