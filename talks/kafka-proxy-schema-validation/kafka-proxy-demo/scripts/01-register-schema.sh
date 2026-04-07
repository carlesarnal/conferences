#!/bin/bash
# Register a JSON Schema for the orders topic with FULL validity enforcement
set -euo pipefail

REGISTRY_URL="${REGISTRY_URL:-http://localhost:8080}"

echo "=== Registering Order Schema ==="
echo ""

curl -s -X POST "$REGISTRY_URL/apis/registry/v3/groups/default/artifacts" \
  -H "Content-Type: application/json" \
  -H "X-Registry-ArtifactId: orders-value" \
  -H "X-Registry-ArtifactType: JSON" \
  -d '{
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
echo ""

curl -s -X POST "$REGISTRY_URL/apis/registry/v3/groups/default/artifacts/orders-value/rules" \
  -H "Content-Type: application/json" \
  -d '{"ruleType": "VALIDITY", "config": "FULL"}'
echo ""

echo "Schema registered with FULL validity enforcement"
echo ""
echo "Contract:"
echo "  - orderId: string (required)"
echo "  - customerId: string (required)"
echo "  - amount: number >= 0 (required)"
echo "  - currency: USD | EUR | GBP (required)"
echo "  - No additional properties allowed"
