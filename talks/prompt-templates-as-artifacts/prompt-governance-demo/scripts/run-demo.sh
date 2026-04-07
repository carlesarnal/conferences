#!/bin/bash
# Run the complete prompt governance demo end-to-end
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==========================================================="
echo "  Prompt Engineering Meets Schema Registry Demo"
echo "==========================================================="
echo ""
echo "Prerequisites:"
echo "  - docker compose up -d (from parent directory)"
echo "  - Apicurio Registry at ${REGISTRY_URL:-http://localhost:8080}"
echo "  - curl and jq installed"
echo ""
echo "For the full RAG chatbot demo, use apicurio-registry-support-chat/"
echo ""

read -p "Press Enter to start..." _

echo ""
echo "STEP 1: Register prompt templates"
echo "==================================="
"$SCRIPT_DIR/01-register-prompts.sh"
echo ""
read -p "Press Enter to continue..." _

echo ""
echo "STEP 2: Prompt versioning"
echo "=========================="
"$SCRIPT_DIR/02-version-prompt.sh"
echo ""
read -p "Press Enter to continue..." _

echo ""
echo "STEP 3: Prompt rendering"
echo "========================="
"$SCRIPT_DIR/03-render-prompt.sh"
echo ""

echo "==========================================================="
echo "  Demo complete!"
echo ""
echo "  Key takeaways:"
echo "  1. Prompts are artifacts — same governance as schemas"
echo "  2. Versioning changes behavior without redeployment"
echo "  3. Variable substitution provides structured templating"
echo "  4. For full RAG demo, use apicurio-registry-support-chat/"
echo "==========================================================="
