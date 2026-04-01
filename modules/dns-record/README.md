# DNS Record Module

Creates a Route 53 alias record pointing to an ALB, with cross-account access support via IAM role assumption.

## Usage

```hcl
module "dns_record" {
  source = "../../modules/dns-record"

  zone_id         = "Z0123456789ABCDEFGHIJ"
  record_name     = "api.nonprod.therj.link"
  alb_dns_name    = module.alb.dns_name
  alb_zone_id     = module.alb.zone_id
  aws_region      = "ap-southeast-1"
  assume_role_arn = "arn:aws:iam::111122223333:role/Route53AccessRole"
}
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
