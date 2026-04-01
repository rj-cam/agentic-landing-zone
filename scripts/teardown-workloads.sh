#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Reverse order: prod first, then nonprod
WORKLOADS=(
  "02-prod"
  "01-nonprod"
)

echo "=== Tearing Down Workloads ==="
echo "WARNING: This will destroy all workload infrastructure."
echo ""

for workload in "${WORKLOADS[@]}"; do
  echo "--- Destroying $workload ---"
  cd "$ROOT_DIR/workloads/$workload"
  terraform init -input=false
  terraform destroy -auto-approve -input=false
  echo ""
done

echo "=== Workloads destroyed. Foundation intact. ==="
