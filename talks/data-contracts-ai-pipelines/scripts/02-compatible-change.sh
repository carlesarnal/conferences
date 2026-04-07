#!/bin/bash
# Demonstrate a compatible schema change (adding an optional field)
set -euo pipefail

REGISTRY_URL="${REGISTRY_URL:-http://localhost:8080}"

echo "=== Compatible Schema Change ==="
echo ""

echo "--- Adding optional 'segment' field to customer-events-value ---"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  "$REGISTRY_URL/apis/registry/v3/groups/data-contracts/artifacts/customer-events-value/versions" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "record",
    "name": "CustomerEvent",
    "namespace": "io.apicurio.demo",
    "fields": [
      {"name": "id", "type": "int"},
      {"name": "first_name", "type": "string"},
      {"name": "last_name", "type": "string"},
      {"name": "email", "type": "string"},
      {"name": "segment", "type": ["null", "string"], "default": null}
    ]
  }')

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | head -n -1)

if [ "$HTTP_CODE" = "200" ]; then
  echo "SUCCESS (HTTP $HTTP_CODE): Version 2 registered"
  echo "Added optional 'segment' field with null default"
  echo ""
  echo "Why this works:"
  echo "  - Adding a nullable field with a default is BACKWARD compatible"
  echo "  - Existing consumers ignore the new field"
  echo "  - New consumers can use 'segment' for ML feature enrichment"
else
  echo "UNEXPECTED (HTTP $HTTP_CODE): $BODY"
fi
echo ""

# Show versions
echo "--- Current versions ---"
curl -s "$REGISTRY_URL/apis/registry/v3/groups/data-contracts/artifacts/customer-events-value/versions" | jq '.versions[] | {version, createdOn}' 2>/dev/null || echo "(install jq for formatted output)"
