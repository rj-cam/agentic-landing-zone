#!/usr/bin/env bash
# Reference script — Phase 0 resources were created manually.
# DO NOT re-run. This documents the CLI commands used.
set -euo pipefail

AWS_REGION="ap-southeast-1"
STATE_BUCKET="rj-landing-zone-tfstate"
LOCK_TABLE="rj-landing-zone-tflock"

echo "Verifying AWS identity..."
aws sts get-caller-identity

echo "Creating S3 state bucket..."
aws s3api create-bucket \
  --bucket "$STATE_BUCKET" \
  --region "$AWS_REGION" \
  --create-bucket-configuration LocationConstraint="$AWS_REGION"

aws s3api put-bucket-versioning \
  --bucket "$STATE_BUCKET" \
  --versioning-configuration Status=Enabled

aws s3api put-public-access-block \
  --bucket "$STATE_BUCKET" \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

echo "Creating DynamoDB lock table..."
aws dynamodb create-table \
  --table-name "$LOCK_TABLE" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$AWS_REGION"

echo "Bootstrap complete."
