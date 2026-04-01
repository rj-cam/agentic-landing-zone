#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

WORKLOADS=(
  "01-nonprod"
  "02-prod"
)

echo "=== Provisioning Workloads ==="

for workload in "${WORKLOADS[@]}"; do
  echo "--- $workload ---"
  cd "$ROOT_DIR/workloads/$workload"
  terraform init -input=false
  terraform apply -auto-approve -input=false
  echo ""
done

echo "=== Workloads provisioned ==="
echo "  Non-Prod: http://nonprod.therj.link"
echo "  Prod:     http://prod.therj.link"
