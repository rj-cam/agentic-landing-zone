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
          var.log_archive_bucket_arn,
          "${var.log_archive_bucket_arn}/*"
        ]
      }
    ]
  })

  target_ids = [var.log_archive_account_id]
}
