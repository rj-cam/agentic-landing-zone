###############################################################################
# SCP — Require Production Tagging
###############################################################################

module "require_prod_tagging" {
  source = "../../modules/scp-policy"

  name        = "require-prod-tagging"
  description = "Deny resource creation in prod without Environment, Owner, and CostCenter tags"

  policy_content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyCreateWithoutRequiredTags"
        Effect = "Deny"
        Action = [
          "ec2:RunInstances",
          "ec2:CreateVolume",
          "rds:CreateDBInstance",
          "s3:CreateBucket",
          "ecs:CreateService",
          "ecs:CreateCluster",
          "elasticloadbalancing:CreateLoadBalancer"
        ]
        Resource = "*"
        Condition = {
          "Null" = {
            "aws:RequestTag/Environment" = "true"
            "aws:RequestTag/Owner"       = "true"
            "aws:RequestTag/CostCenter"  = "true"
          }
        }
      }
    ]
  })

  target_ids = [local.ou_ids["prod"]]
}
