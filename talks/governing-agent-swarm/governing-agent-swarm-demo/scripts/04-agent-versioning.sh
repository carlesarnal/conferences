#!/bin/bash
# Demonstrate agent versioning — evolving capabilities without breaking consumers
set -euo pipefail

REGISTRY_URL="${REGISTRY_URL:-http://localhost:8080}"

echo "=== Agent Versioning Demo ==="
echo ""

echo "--- Current fraud-detection-agent (v2.1.0) ---"
curl -s "$REGISTRY_URL/apis/registry/v3/groups/agents/artifacts/fraud-detection-agent/versions/latest/content" | jq '.version, .skills[].name' 2>/dev/null
echo ""

echo "--- Upgrading to v3.0.0 (adding new skill + capability) ---"
curl -s -X POST "$REGISTRY_URL/apis/registry/v3/groups/agents/artifacts/fraud-detection-agent/versions" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Fraud Detection Agent",
    "description": "Analyzes transactions for fraud indicators with ML-based scoring",
    "url": "https://agents.internal/fraud",
    "version": "3.0.0",
    "capabilities": {"streaming": true, "realtime": true, "mlScoring": true},
    "skills": [
      {"id": "score-transaction", "name": "Transaction Scoring", "inputModes": ["json"], "outputModes": ["json"]},
      {"id": "flag-account", "name": "Account Flagging", "inputModes": ["json"], "outputModes": ["json"]},
      {"id": "explain-decision", "name": "Decision Explanation", "inputModes": ["json"], "outputModes": ["text"]}
    ]
  }'
echo ""

echo "--- All versions ---"
curl -s "$REGISTRY_URL/apis/registry/v3/groups/agents/artifacts/fraud-detection-agent/versions" | jq '.versions[] | {version, createdOn}' 2>/dev/null
echo ""

echo "KEY POINT: v2.1.0 is still available for agents that haven't migrated"
echo "New agents can discover and use the 'explain-decision' skill from v3.0.0"
