#!/bin/bash
# Demonstrate agent discovery queries
set -euo pipefail

REGISTRY_URL="${REGISTRY_URL:-http://localhost:8080}"

echo "=== Agent Discovery Demo ==="
echo ""

echo "--- List all registered agents ---"
curl -s "$REGISTRY_URL/apis/registry/v3/groups/agents/artifacts" | jq '.artifacts[] | {artifactId, name}' 2>/dev/null
echo ""

echo "--- Get fraud-detection-agent capabilities (latest) ---"
curl -s "$REGISTRY_URL/apis/registry/v3/groups/agents/artifacts/fraud-detection-agent/versions/latest/content" | jq '{name, version, capabilities, skills: [.skills[].name]}' 2>/dev/null
echo ""

echo "--- Search agents by name ---"
curl -s "$REGISTRY_URL/apis/registry/v3/search/artifacts?groupId=agents&name=Fraud" | jq '.artifacts[] | {artifactId, name}' 2>/dev/null
echo ""

echo "--- List all communication contracts ---"
curl -s "$REGISTRY_URL/apis/registry/v3/groups/agent-contracts/artifacts" | jq '.artifacts[] | {artifactId, name}' 2>/dev/null
echo ""

echo "--- List all registered models ---"
curl -s "$REGISTRY_URL/apis/registry/v3/groups/models/artifacts" | jq '.artifacts[] | {artifactId, name}' 2>/dev/null
