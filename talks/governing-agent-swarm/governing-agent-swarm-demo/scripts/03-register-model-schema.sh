#!/bin/bash
# Register model metadata schema and validate model submissions
set -euo pipefail

REGISTRY_URL="${REGISTRY_URL:-http://localhost:8080}"

echo "=== Registering Model Metadata Schema ==="
echo ""

echo "--- Model Context Schema ---"
curl -s -X POST "$REGISTRY_URL/apis/registry/v3/groups/models/artifacts" \
  -H "Content-Type: application/json" \
  -H "X-Registry-ArtifactId: model-context-schema" \
  -H "X-Registry-ArtifactType: JSON" \
  -d '{
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "title": "ModelContext",
    "type": "object",
    "required": ["modelId", "version", "provider", "artifactUri", "metrics"],
    "properties": {
      "modelId": {"type": "string"},
      "version": {"type": "string"},
      "provider": {"type": "string"},
      "description": {"type": "string"},
      "artifactUri": {"type": "string", "format": "uri"},
      "metrics": {
        "type": "object",
        "required": ["accuracy"],
        "properties": {
          "accuracy": {"type": "number", "minimum": 0, "maximum": 1},
          "f1Score": {"type": "number", "minimum": 0, "maximum": 1},
          "latencyMs": {"type": "number", "minimum": 0}
        }
      },
      "capabilities": {
        "type": "array",
        "items": {"type": "string"}
      }
    }
  }'
echo ""

# Enable validation
curl -s -X POST "$REGISTRY_URL/apis/registry/v3/groups/models/artifacts/model-context-schema/rules" \
  -H "Content-Type: application/json" \
  -d '{"ruleType": "VALIDITY", "config": "FULL"}'
echo "Schema registered with FULL validity enforcement"
echo ""

echo "--- Registering a valid model ---"
curl -s -X POST "$REGISTRY_URL/apis/registry/v3/groups/models/artifacts" \
  -H "Content-Type: application/json" \
  -H "X-Registry-ArtifactId: customer-churn-predictor" \
  -H "X-Registry-ArtifactType: JSON" \
  -d '{
    "modelId": "customer-churn-predictor",
    "version": "1.2.0",
    "provider": "internal-ml-team",
    "description": "Predicts customer churn probability based on usage patterns",
    "artifactUri": "s3://ml-models/churn-predictor/v1.2.0/model.onnx",
    "metrics": {
      "accuracy": 0.92,
      "f1Score": 0.89,
      "latencyMs": 45
    },
    "capabilities": ["batch", "streaming", "explainability"]
  }'
echo ""
echo "Valid model registered successfully"
echo ""

echo "=== Model governance layer ready ==="
