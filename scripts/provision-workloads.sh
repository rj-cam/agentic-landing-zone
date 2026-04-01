#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Provisioning Workloads ==="

###############################################################################
# Extract account IDs from 01-organization outputs
###############################################################################
echo "--- Reading account IDs from organization state ---"
cd "$ROOT_DIR/foundation/01-organization"
terraform init -input=false > /dev/null
NONPROD_ACCOUNT_ID=$(terraform output -raw nonprod_account_id)
PROD_ACCOUNT_ID=$(terraform output -raw prod_account_id)

echo "  Non-Prod: $NONPROD_ACCOUNT_ID"
echo "  Prod:     $PROD_ACCOUNT_ID"
echo ""

###############################################################################
# Non-Prod workload
###############################################################################
echo "--- 01-nonprod ---"
cd "$ROOT_DIR/workloads/01-nonprod"
terraform init -input=false
terraform apply -auto-approve -input=false \
  -var="account_id=$NONPROD_ACCOUNT_ID"
echo ""

###############################################################################
# Prod workload
###############################################################################
echo "--- 02-prod ---"
cd "$ROOT_DIR/workloads/02-prod"
terraform init -input=false
terraform apply -auto-approve -input=false \
  -var="account_id=$PROD_ACCOUNT_ID"
echo ""

echo "=== Workloads provisioned ==="
echo "  Non-Prod: https://nonprod.therj.link"
echo "  Prod:     https://prod.therj.link"
