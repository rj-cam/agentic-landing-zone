#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

LAYERS=(
  "01-organization"
  "02-scps"
  "03-identity-center"
  "04-logging"
  "05-networking"
  "06-shared-services"
)

echo "=== Provisioning Foundation Layers ==="
echo "Terraform version: $(terraform version -json | head -1)"
echo ""

for layer in "${LAYERS[@]}"; do
  echo "--- $layer ---"
  cd "$ROOT_DIR/foundation/$layer"
  terraform init -input=false
  terraform apply -auto-approve -input=false
  echo ""
done

echo "=== Foundation provisioned ==="
echo "Run provision-workloads.sh to deploy services."
