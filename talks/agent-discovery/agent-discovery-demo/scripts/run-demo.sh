#!/bin/bash
# Run the full agent discovery demo end-to-end
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REGISTRY_URL="${REGISTRY_URL:-http://localhost:8080}"

echo "============================================"
echo " Agent Discovery Demo with Apicurio Registry"
echo "============================================"
echo ""

# Wait for registry
echo "Waiting for Apicurio Registry at $REGISTRY_URL..."
until curl -sf "$REGISTRY_URL/health" > /dev/null 2>&1; do
  sleep 2
done
echo "Registry is ready!"
echo ""

# Run all steps
bash "$SCRIPT_DIR/01-register-agents.sh"
echo ""
echo "--------------------------------------------"
echo ""
bash "$SCRIPT_DIR/02-register-prompts.sh"
echo ""
echo "--------------------------------------------"
echo ""
bash "$SCRIPT_DIR/03-register-model-schemas.sh"
echo ""
echo "--------------------------------------------"
echo ""
bash "$SCRIPT_DIR/04-discover-agents.sh"
echo ""
echo "============================================"
echo " Demo complete!"
echo " Registry UI: $REGISTRY_URL"
echo "============================================"
