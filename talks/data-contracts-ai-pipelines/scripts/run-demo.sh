#!/bin/bash
# Run the complete data contracts demo end-to-end
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "============================================"
echo "  Data Contracts for Event-Driven AI Demo"
echo "============================================"
echo ""
echo "Prerequisites:"
echo "  - Apicurio Registry running at ${REGISTRY_URL:-http://localhost:8080}"
echo "  - curl and jq installed"
echo ""

read -p "Press Enter to start..." _

echo ""
echo "STEP 1: Register data contracts"
echo "================================"
"$SCRIPT_DIR/01-register-contracts.sh"
echo ""
read -p "Press Enter to continue..." _

echo ""
echo "STEP 2: Compatible schema change"
echo "================================="
"$SCRIPT_DIR/02-compatible-change.sh"
echo ""
read -p "Press Enter to continue..." _

echo ""
echo "STEP 3: Breaking schema change (rejected)"
echo "==========================================="
"$SCRIPT_DIR/03-breaking-change.sh"
echo ""

echo "============================================"
echo "  Demo complete!"
echo ""
echo "  Key takeaways:"
echo "  1. Data contract = schema + compatibility rule"
echo "  2. Compatible changes pass, breaking changes are rejected"
echo "  3. Validation happens at registration, not at inference"
echo "============================================"
