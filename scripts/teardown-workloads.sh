#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Tearing Down Workloads ==="
echo "WARNING: This will destroy all workload infrastructure."
echo ""

###############################################################################
# Extract account IDs from 01-organization outputs
###############################################################################
cd "$ROOT_DIR/foundation/01-organization"
terraform init -input=false > /dev/null
NONPROD_ACCOUNT_ID=$(terraform output -raw nonprod_account_id)
PROD_ACCOUNT_ID=$(terraform output -raw prod_account_id)

###############################################################################
# Destroy in reverse order: prod first, then nonprod
###############################################################################
echo "--- Destroying 02-prod ---"
cd "$ROOT_DIR/workloads/02-prod"
terraform init -input=false
terraform destroy -auto-approve -input=false \
  -var="prod_account_id=$PROD_ACCOUNT_ID"
echo ""

echo "--- Destroying 01-nonprod ---"
cd "$ROOT_DIR/workloads/01-nonprod"
terraform init -input=false
terraform destroy -auto-approve -input=false \
  -var="nonprod_account_id=$NONPROD_ACCOUNT_ID"
echo ""

echo "=== Workloads destroyed. Foundation intact. ==="
