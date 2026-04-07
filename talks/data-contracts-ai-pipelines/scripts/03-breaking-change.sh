#!/bin/bash
# Demonstrate a breaking schema change (should be REJECTED by the registry)
set -euo pipefail

REGISTRY_URL="${REGISTRY_URL:-http://localhost:8080}"

echo "=== Breaking Schema Change (should fail) ==="
echo ""

echo "--- Attempting to remove 'first_name' and 'last_name', add 'full_name' ---"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  "$REGISTRY_URL/apis/registry/v3/groups/data-contracts/artifacts/customer-events-value/versions" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "record",
    "name": "CustomerEvent",
    "namespace": "io.apicurio.demo",
    "fields": [
      {"name": "id", "type": "int"},
      {"name": "full_name", "type": "string"},
      {"name": "email", "type": "string"}
    ]
  }')

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | head -n -1)

if [ "$HTTP_CODE" = "409" ] || [ "$HTTP_CODE" = "400" ]; then
  echo "REJECTED (HTTP $HTTP_CODE) — as expected!"
  echo ""
  echo "The registry prevented a breaking change:"
  echo "  - Removing 'first_name' and 'last_name' breaks existing consumers"
  echo "  - Adding 'full_name' is not a compatible replacement"
  echo "  - An ML model expecting 'first_name' would crash at inference time"
  echo ""
  echo "KEY POINT: The data contract caught this BEFORE it entered Kafka."
  echo "Without the contract, this would be a 3 AM production incident."
else
  echo "UNEXPECTED (HTTP $HTTP_CODE): $BODY"
  echo "Expected 409 Conflict — check that BACKWARD compatibility rule is set."
fi
