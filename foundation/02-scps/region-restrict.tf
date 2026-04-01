###############################################################################
# SCP — Region Restrict
###############################################################################

module "region_restrict" {
  source = "../../modules/scp-policy"

  name        = "region-restrict"
  description = "Deny all actions outside ap-southeast-1 and us-east-1, excluding global services"

  policy_content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyNonApprovedRegions"
        Effect = "Deny"
        NotAction = [
          "iam:*",
          "organizations:*",
          "sts:*",
          "cloudfront:*",
          "route53:*",
          "support:*",
          "budgets:*",
          "waf:*",
          "wafv2:*",
          "cloudwatch:*"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = [
              "ap-southeast-1",
              "us-east-1"
            ]
          }
        }
      }
    ]
  })

  target_ids = [local.root_id]
}
