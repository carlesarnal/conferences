#!/bin/bash
# Run the complete governing-agent-swarm demo end-to-end
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "================================================"
echo "  Governing the Agent Swarm Demo"
echo "================================================"
echo ""
echo "Prerequisites:"
echo "  - docker compose up -d (from parent directory)"
echo "  - Apicurio Registry at ${REGISTRY_URL:-http://localhost:8080}"
echo "  - curl and jq installed"
echo ""

read -p "Press Enter to start..." _

echo ""
echo "STEP 1: Register AI Agents (A2A discovery)"
echo "============================================="
"$SCRIPT_DIR/01-register-agents.sh"
echo ""
read -p "Press Enter to continue..." _

echo ""
echo "STEP 2: Define communication contracts"
echo "========================================"
"$SCRIPT_DIR/02-register-contracts.sh"
echo ""
read -p "Press Enter to continue..." _

echo ""
echo "STEP 3: Model metadata governance"
echo "==================================="
"$SCRIPT_DIR/03-register-model-schema.sh"
echo ""
read -p "Press Enter to continue..." _

echo ""
echo "STEP 4: Agent versioning"
echo "========================="
"$SCRIPT_DIR/04-agent-versioning.sh"
echo ""
read -p "Press Enter to continue..." _

echo ""
echo "STEP 5: Agent discovery queries"
echo "================================"
"$SCRIPT_DIR/05-discover-agents.sh"
echo ""

echo "================================================"
echo "  Demo complete!"
echo ""
echo "  Three layers of governance demonstrated:"
echo "  1. Discovery — A2A Agent Cards in the registry"
echo "  2. Contracts — Request/response schemas with compatibility"
echo "  3. Metadata — Model schemas validated at registration"
echo "================================================"
