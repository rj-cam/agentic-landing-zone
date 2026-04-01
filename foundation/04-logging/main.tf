###############################################################################
# Data Sources
###############################################################################

data "terraform_remote_state" "organization" {
  backend = "s3"
  config = {
    bucket = "rj-landing-zone-tfstate"
    key    = "foundation/01-organization/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "aws_caller_identity" "management" {}

data "aws_organizations_organization" "current" {}

###############################################################################
# S3 Bucket - Log Archive Account
###############################################################################

resource "aws_s3_bucket" "cloudtrail_logs" {
  provider = aws.log_archive
  bucket   = var.log_bucket_name
}

resource "aws_s3_bucket_versioning" "cloudtrail_logs" {
  provider = aws.log_archive
  bucket   = aws_s3_bucket.cloudtrail_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs" {
  provider = aws.log_archive
  bucket   = aws_s3_bucket.cloudtrail_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_logs" {
  provider = aws.log_archive
  bucket   = aws_s3_bucket.cloudtrail_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail_logs" {
  provider = aws.log_archive
  bucket   = aws_s3_bucket.cloudtrail_logs.id

  rule {
    id     = "archive-and-expire"
    status = "Enabled"

    filter {}

    transition {
      days          = var.glacier_transition_days
      storage_class = "GLACIER_IR"
    }

    expiration {
      days = var.log_retention_days
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  provider = aws.log_archive
  bucket   = aws_s3_bucket.cloudtrail_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.cloudtrail_logs.arn,
          "${aws_s3_bucket.cloudtrail_logs.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail_logs.arn
        Condition = {
          StringEquals = {
            "aws:SourceOrgID" = data.aws_organizations_organization.current.id
          }
        }
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl"    = "bucket-owner-full-control"
            "aws:SourceOrgID" = data.aws_organizations_organization.current.id
          }
        }
      }
    ]
  })
}

###############################################################################
# CloudTrail - Management Account
###############################################################################

resource "aws_cloudtrail" "org_trail" {
  name                       = "org-trail"
  s3_bucket_name             = aws_s3_bucket.cloudtrail_logs.bucket
  is_organization_trail      = true
  is_multi_region_trail      = true
  enable_log_file_validation = true
  enable_logging             = true

  depends_on = [aws_s3_bucket_policy.cloudtrail_logs]
}
