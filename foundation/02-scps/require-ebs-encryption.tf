###############################################################################
# SCP — Require EBS Encryption
###############################################################################

module "require_ebs_encryption" {
  source = "../../modules/scp-policy"

  name        = "require-ebs-encryption"
  description = "Deny ec2:RunInstances if EBS volumes are not encrypted"

  policy_content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyUnencryptedEBSVolumes"
        Effect   = "Deny"
        Action   = "ec2:RunInstances"
        Resource = "arn:aws:ec2:*:*:volume/*"
        Condition = {
          Bool = {
            "ec2:Encrypted" = "false"
          }
        }
      }
    ]
  })

  target_ids = [local.root_id]
}
