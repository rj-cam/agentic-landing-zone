###############################################################################
# SCP — Require S3 Encryption and Secure Transport
###############################################################################

module "require_s3_encryption" {
  source = "../../modules/scp-policy"

  name        = "require-s3-encryption"
  description = "Deny S3 PutObject without encryption and deny non-HTTPS requests"

  policy_content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyUnencryptedS3Puts"
        Effect   = "Deny"
        Action   = "s3:PutObject"
        Resource = "*"
        Condition = {
          StringNotEqualsIfExists = {
            "s3:x-amz-server-side-encryption" = [
              "AES256",
              "aws:kms"
            ]
          }
        }
      },
      {
        Sid      = "DenyInsecureTransport"
        Effect   = "Deny"
        Action   = "s3:PutObject"
        Resource = "*"
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })

  target_ids = [local.root_id]
}
