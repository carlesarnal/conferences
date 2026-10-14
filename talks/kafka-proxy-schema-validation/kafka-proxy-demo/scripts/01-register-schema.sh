#!/bin/bash
# Register the order JSON Schema, then start Kroxylicious configured to enforce it
set -euo pipefail
cd "$(dirname "$0")/.."

REGISTRY_URL="${REGISTRY_URL:-http://localhost:8080}"

echo "=== Registering Order Schema (Apicurio Registry v3 API) ==="

SCHEMA='{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "Order",
  "type": "object",
  "required": ["orderId", "customerId", "amount", "currency"],
  "properties": {
    "orderId": {"type": "string"},
    "customerId": {"type": "string"},
    "amount": {"type": "number", "minimum": 0},
    "currency": {"type": "string", "enum": ["USD", "EUR", "GBP"]}
  },
  "additionalProperties": false
}'

BODY=$(jq -n --arg content "$SCHEMA" '{
  artifactId: "orders-value",
  artifactType: "JSON",
  firstVersion: {content: {content: $content, contentType: "application/json"}}
}')

RESPONSE=$(curl -sf -X POST "$REGISTRY_URL/apis/registry/v3/groups/default/artifacts?ifExists=FIND_OR_CREATE_VERSION" \
  -H "Content-Type: application/json" -d "$BODY")

CONTENT_ID=$(echo "$RESPONSE" | jq -r '.version.contentId')
if [ -z "$CONTENT_ID" ] || [ "$CONTENT_ID" = "null" ]; then
  echo "Could not read contentId from registry response:" >&2
  echo "$RESPONSE" >&2
  exit 1
fi
echo "Registered orders-value, contentId=$CONTENT_ID"

mkdir -p generated
sed "s/__CONTENT_ID__/$CONTENT_ID/" proxy-config.template.yaml > generated/proxy-config.yaml
echo "Rendered generated/proxy-config.yaml with apicurioId=$CONTENT_ID"
echo ""

echo "=== Starting Kroxylicious ==="
docker compose --profile proxy up -d kroxylicious
echo -n "Waiting for proxy"
until docker logs kroxylicious 2>&1 | grep -q -i "started\|listening\|bound"; do
  if [ "$(docker inspect -f '{{.State.Running}}' kroxylicious 2>/dev/null)" != "true" ]; then
    echo ""; echo "Kroxylicious exited:" >&2; docker logs kroxylicious 2>&1 | tail -30 >&2; exit 1
  fi
  echo -n "."; sleep 2
done
echo " ready"
