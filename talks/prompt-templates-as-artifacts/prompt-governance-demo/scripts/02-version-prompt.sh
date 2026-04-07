#!/bin/bash
# Demonstrate prompt versioning — update the system prompt behavior without redeploying code
set -euo pipefail

REGISTRY_URL="${REGISTRY_URL:-http://localhost:8080}"

echo "=== Prompt Versioning Demo ==="
echo ""

echo "--- Current system prompt (v1) ---"
curl -s "$REGISTRY_URL/apis/registry/v3/groups/prompts/artifacts/support-system-prompt/versions/latest/content" | jq '.template' 2>/dev/null
echo ""

echo "--- Creating v2: adding code examples requirement + new artifact types ---"
curl -s -X POST "$REGISTRY_URL/apis/registry/v3/groups/prompts/artifacts/support-system-prompt/versions" \
  -H "Content-Type: application/json" \
  -d '{
    "template": "You are a helpful support assistant for Apicurio Registry, a CNCF sandbox project.\n\nSupported artifact types: {{supported_artifact_types}}\n\nALWAYS include code examples in your responses when applicable.\nWhen showing API calls, use curl examples.\n{{additional_context}}",
    "variables": {
      "supported_artifact_types": {"type": "string", "default": "AVRO, PROTOBUF, JSON, OPENAPI, ASYNCAPI, PROMPT_TEMPLATE, MODEL_SCHEMA"},
      "additional_context": {"type": "string", "default": ""}
    }
  }'
echo ""

echo "--- Version history ---"
curl -s "$REGISTRY_URL/apis/registry/v3/groups/prompts/artifacts/support-system-prompt/versions" | jq '.versions[] | {version, createdOn}' 2>/dev/null
echo ""

echo "KEY POINT: Application behavior changed without redeployment"
echo "  v1: general answers, 5 artifact types"
echo "  v2: always includes code examples, 7 artifact types (added PROMPT_TEMPLATE, MODEL_SCHEMA)"
echo ""
echo "Both versions remain accessible — consumers choose which version to use"
