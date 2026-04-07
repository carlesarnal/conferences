#!/bin/bash
# Register agent communication contracts (request/response schemas) with compatibility rules
set -euo pipefail

REGISTRY_URL="${REGISTRY_URL:-http://localhost:8080}"

echo "=== Registering Communication Contracts ==="
echo ""

echo "--- Fraud Detection Request Schema ---"
curl -s -X POST "$REGISTRY_URL/apis/registry/v3/groups/agent-contracts/artifacts" \
  -H "Content-Type: application/json" \
  -H "X-Registry-ArtifactId: fraud-detection-request" \
  -H "X-Registry-ArtifactType: JSON" \
  -d '{
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "title": "FraudDetectionRequest",
    "type": "object",
    "required": ["transactionId", "amount", "currency", "customerId", "timestamp"],
    "properties": {
      "transactionId": {"type": "string"},
      "amount": {"type": "number", "minimum": 0},
      "currency": {"type": "string"},
      "customerId": {"type": "string"},
      "timestamp": {"type": "string", "format": "date-time"},
      "metadata": {"type": "object"}
    }
  }'
echo ""

echo "--- Fraud Detection Response Schema ---"
curl -s -X POST "$REGISTRY_URL/apis/registry/v3/groups/agent-contracts/artifacts" \
  -H "Content-Type: application/json" \
  -H "X-Registry-ArtifactId: fraud-detection-response" \
  -H "X-Registry-ArtifactType: JSON" \
  -d '{
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "title": "FraudDetectionResponse",
    "type": "object",
    "required": ["transactionId", "riskScore", "decision"],
    "properties": {
      "transactionId": {"type": "string"},
      "riskScore": {"type": "number", "minimum": 0, "maximum": 1},
      "decision": {"type": "string", "enum": ["APPROVE", "FLAG", "BLOCK"]},
      "reasons": {"type": "array", "items": {"type": "string"}}
    }
  }'
echo ""

echo "--- Enabling BACKWARD compatibility on contracts ---"
curl -s -X POST "$REGISTRY_URL/apis/registry/v3/groups/agent-contracts/artifacts/fraud-detection-request/rules" \
  -H "Content-Type: application/json" \
  -d '{"ruleType": "COMPATIBILITY", "config": "BACKWARD"}'

curl -s -X POST "$REGISTRY_URL/apis/registry/v3/groups/agent-contracts/artifacts/fraud-detection-response/rules" \
  -H "Content-Type: application/json" \
  -d '{"ruleType": "COMPATIBILITY", "config": "BACKWARD"}'
echo ""

echo "=== Communication contracts registered with BACKWARD compatibility ==="
