################################################################################
# Cross-account DNS role – deployed in Management account
################################################################################

resource "aws_iam_role" "route53_record_manager" {
  name = "route53-record-manager"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${var.nonprod_account_id}:root",
            "arn:aws:iam::${var.prod_account_id}:root",
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "route53-record-manager"
  }
}

resource "aws_iam_role_policy" "route53_records" {
  name = "route53-records"
  role = aws_iam_role.route53_record_manager.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "route53:ChangeResourceRecordSets"
        Resource = "arn:aws:route53:::hostedzone/${var.hosted_zone_id}"
      },
      {
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:GetHostedZone",
        ]
        Resource = "*"
      }
    ]
  })
}
