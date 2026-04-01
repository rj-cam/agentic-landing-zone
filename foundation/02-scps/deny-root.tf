###############################################################################
# SCP — Deny Root User
###############################################################################

module "deny_root" {
  source = "../../modules/scp-policy"

  name        = "deny-root"
  description = "Deny all actions performed by the root user"

  policy_content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyRootUser"
        Effect   = "Deny"
        Action   = "*"
        Resource = "*"
        Condition = {
          StringLike = {
            "aws:PrincipalArn" = "arn:aws:iam::*:root"
          }
        }
      }
    ]
  })

  target_ids = [local.root_id]
}
