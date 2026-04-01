#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Provisioning Foundation Layers ==="
echo "Terraform version: $(terraform version -json | head -1)"
echo ""

###############################################################################
# Layer 01 — Organization (creates accounts, no extra vars needed)
###############################################################################
echo "--- 01-organization ---"
cd "$ROOT_DIR/foundation/01-organization"
terraform init -input=false
terraform apply -auto-approve -input=false
echo ""

###############################################################################
# Extract account IDs from 01-organization outputs
###############################################################################
echo "--- Extracting account IDs from organization outputs ---"
LOG_ARCHIVE_ACCOUNT_ID=$(terraform output -raw log_archive_account_id)
SHARED_SERVICES_ACCOUNT_ID=$(terraform output -raw shared_services_account_id)
NONPROD_ACCOUNT_ID=$(terraform output -raw nonprod_account_id)
PROD_ACCOUNT_ID=$(terraform output -raw prod_account_id)

echo "  Log Archive:     $LOG_ARCHIVE_ACCOUNT_ID"
echo "  Shared Services: $SHARED_SERVICES_ACCOUNT_ID"
echo "  Non-Prod:        $NONPROD_ACCOUNT_ID"
echo "  Prod:            $PROD_ACCOUNT_ID"
echo ""

###############################################################################
# Layer 02 — SCPs (no account ID vars needed — uses remote state)
###############################################################################
echo "--- 02-scps ---"
cd "$ROOT_DIR/foundation/02-scps"
terraform init -input=false
terraform apply -auto-approve -input=false
echo ""

###############################################################################
# Layer 03 — Identity Center (no account ID vars needed — uses remote state)
###############################################################################
echo "--- 03-identity-center ---"
cd "$ROOT_DIR/foundation/03-identity-center"
terraform init -input=false
terraform apply -auto-approve -input=false
echo ""

###############################################################################
# Layer 04 — Logging (needs log_archive_account_id for provider)
###############################################################################
echo "--- 04-logging ---"
cd "$ROOT_DIR/foundation/04-logging"
terraform init -input=false
terraform apply -auto-approve -input=false \
  -var="log_archive_account_id=$LOG_ARCHIVE_ACCOUNT_ID"
echo ""

###############################################################################
# Layer 05 — Networking (needs shared_services_account_id for provider)
###############################################################################
echo "--- 05-networking ---"
cd "$ROOT_DIR/foundation/05-networking"
terraform init -input=false
terraform apply -auto-approve -input=false \
  -var="shared_services_account_id=$SHARED_SERVICES_ACCOUNT_ID"
echo ""

###############################################################################
# Layer 06 — Shared Services (needs shared_services_account_id for provider)
###############################################################################
echo "--- 06-shared-services ---"
cd "$ROOT_DIR/foundation/06-shared-services"
terraform init -input=false
terraform apply -auto-approve -input=false \
  -var="shared_services_account_id=$SHARED_SERVICES_ACCOUNT_ID"
echo ""

echo "=== Foundation provisioned ==="
echo ""
echo "Account IDs (save these for workload provisioning):"
echo "  LOG_ARCHIVE_ACCOUNT_ID=$LOG_ARCHIVE_ACCOUNT_ID"
echo "  SHARED_SERVICES_ACCOUNT_ID=$SHARED_SERVICES_ACCOUNT_ID"
echo "  NONPROD_ACCOUNT_ID=$NONPROD_ACCOUNT_ID"
echo "  PROD_ACCOUNT_ID=$PROD_ACCOUNT_ID"
echo ""
echo "Run provision-workloads.sh to deploy services."
