#!/bin/bash
# Register A2A Agent Cards in Apicurio Registry for discovery
set -euo pipefail

REGISTRY_URL="${REGISTRY_URL:-http://localhost:8080}"

echo "=== Registering AI Agents ==="
echo ""

echo "--- Data Enrichment Agent ---"
curl -s -X POST "$REGISTRY_URL/apis/registry/v3/groups/agents/artifacts" \
  -H "Content-Type: application/json" \
  -H "X-Registry-ArtifactId: data-enrichment-agent" \
  -H "X-Registry-ArtifactType: JSON" \
  -d '{
    "name": "Data Enrichment Agent",
    "description": "Enriches customer data with external sources",
    "url": "https://agents.internal/enrichment",
    "version": "1.0.0",
    "capabilities": {"streaming": true, "batchProcessing": true},
    "skills": [
      {"id": "enrich-customer", "name": "Customer Enrichment", "inputModes": ["json"], "outputModes": ["json"]},
      {"id": "enrich-address", "name": "Address Validation", "inputModes": ["json"], "outputModes": ["json"]}
    ]
  }'
echo ""

echo "--- Fraud Detection Agent ---"
curl -s -X POST "$REGISTRY_URL/apis/registry/v3/groups/agents/artifacts" \
  -H "Content-Type: application/json" \
  -H "X-Registry-ArtifactId: fraud-detection-agent" \
  -H "X-Registry-ArtifactType: JSON" \
  -d '{
    "name": "Fraud Detection Agent",
    "description": "Analyzes transactions for fraud indicators",
    "url": "https://agents.internal/fraud",
    "version": "2.1.0",
    "capabilities": {"streaming": true, "realtime": true},
    "skills": [
      {"id": "score-transaction", "name": "Transaction Scoring", "inputModes": ["json"], "outputModes": ["json"]},
      {"id": "flag-account", "name": "Account Flagging", "inputModes": ["json"], "outputModes": ["json"]}
    ]
  }'
echo ""

echo "--- Summarization Agent ---"
curl -s -X POST "$REGISTRY_URL/apis/registry/v3/groups/agents/artifacts" \
  -H "Content-Type: application/json" \
  -H "X-Registry-ArtifactId: summarization-agent" \
  -H "X-Registry-ArtifactType: JSON" \
  -d '{
    "name": "Summarization Agent",
    "description": "Generates summaries of text documents",
    "url": "https://agents.internal/summarizer",
    "version": "1.0.0",
    "capabilities": {"streaming": true},
    "skills": [
      {"id": "summarize", "name": "Text Summarization", "inputModes": ["text"], "outputModes": ["text"]}
    ]
  }'
echo ""

echo "=== 3 agents registered in group 'agents' ==="
