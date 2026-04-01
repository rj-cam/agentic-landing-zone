# SCP Policy Module

Creates an AWS Organizations Service Control Policy and attaches it to the specified organizational units or accounts.

## Usage

```hcl
module "deny_regions_scp" {
  source = "../../modules/scp-policy"

  name        = "deny-unapproved-regions"
  description = "Deny access to AWS regions outside ap-southeast-1"

  policy_content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "DenyUnapprovedRegions"
      Effect    = "Deny"
      Action    = "*"
      Resource  = "*"
      Condition = {
        StringNotEquals = {
          "aws:RequestedRegion" = ["ap-southeast-1"]
        }
      }
    }]
  })

  target_ids = ["ou-abc1-23456789"]

  tags = {
    Project = "agentic-landing-zone"
  }
}
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
