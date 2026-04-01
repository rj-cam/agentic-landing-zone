###############################################################################
# SCP — Protect Log Archive
###############################################################################

module "protect_log_archive" {
  source = "../../modules/scp-policy"

  name        = "protect-log-archive"
  description = "Deny deletion and policy changes on the Log Archive S3 bucket"

  policy_content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ProtectLogArchiveBucket"
        Effect = "Deny"
        Action = [
          "s3:DeleteBucket",
          "s3:DeleteObject",
          "s3:PutBucketPolicy"
        ]
        Resource = [
          "arn:aws:s3:::landing-zone-cloudtrail-logs",
          "arn:aws:s3:::landing-zone-cloudtrail-logs/*"
        ]
      }
    ]
  })

  target_ids = [local.log_archive_account_id]
}
