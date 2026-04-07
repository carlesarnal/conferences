#!/bin/bash
# Register data contracts (input + output schemas) with compatibility rules
set -euo pipefail

REGISTRY_URL="${REGISTRY_URL:-http://localhost:8080}"

echo "=== Registering Data Contracts ==="
echo ""

# Register the CDC input schema (data contract between producer and consumers)
echo "--- Registering input contract: customer-events-value ---"
curl -s -X POST "$REGISTRY_URL/apis/registry/v3/groups/data-contracts/artifacts" \
  -H "Content-Type: application/json" \
  -H "X-Registry-ArtifactId: customer-events-value" \
  -H "X-Registry-ArtifactType: AVRO" \
  -d '{
    "type": "record",
    "name": "CustomerEvent",
    "namespace": "io.apicurio.demo",
    "fields": [
      {"name": "id", "type": "int"},
      {"name": "first_name", "type": "string"},
      {"name": "last_name", "type": "string"},
      {"name": "email", "type": "string"}
    ]
  }'
echo ""

# Enforce BACKWARD compatibility
curl -s -X POST "$REGISTRY_URL/apis/registry/v3/groups/data-contracts/artifacts/customer-events-value/rules" \
  -H "Content-Type: application/json" \
  -d '{"ruleType": "COMPATIBILITY", "config": "BACKWARD"}'
echo "Input contract registered with BACKWARD compatibility"
echo ""

# Register the ML prediction output schema
echo "--- Registering output contract: predictions-value ---"
curl -s -X POST "$REGISTRY_URL/apis/registry/v3/groups/data-contracts/artifacts" \
  -H "Content-Type: application/json" \
  -H "X-Registry-ArtifactId: predictions-value" \
  -H "X-Registry-ArtifactType: AVRO" \
  -d '{
    "type": "record",
    "name": "Prediction",
    "namespace": "io.apicurio.demo",
    "fields": [
      {"name": "customer_id", "type": "int"},
      {"name": "prediction", "type": "string"},
      {"name": "confidence", "type": "double"},
      {"name": "model_version", "type": "string"},
      {"name": "timestamp", "type": "long"}
    ]
  }'
echo ""

curl -s -X POST "$REGISTRY_URL/apis/registry/v3/groups/data-contracts/artifacts/predictions-value/rules" \
  -H "Content-Type: application/json" \
  -d '{"ruleType": "COMPATIBILITY", "config": "BACKWARD"}'
echo "Output contract registered with BACKWARD compatibility"
echo ""

echo "=== Data contracts registered ==="
echo "Input:  customer-events-value (Avro, BACKWARD)"
echo "Output: predictions-value (Avro, BACKWARD)"
