#!/bin/bash
# Register prompt templates as PROMPT_TEMPLATE artifacts in Apicurio Registry
set -euo pipefail

REGISTRY_URL="${REGISTRY_URL:-http://localhost:8080}"

echo "=== Registering Prompt Templates ==="
echo ""

echo "--- System Prompt (v1) ---"
curl -s -X POST "$REGISTRY_URL/apis/registry/v3/groups/prompts/artifacts" \
  -H "Content-Type: application/json" \
  -H "X-Registry-ArtifactId: support-system-prompt" \
  -H "X-Registry-ArtifactType: JSON" \
  -d '{
    "template": "You are a helpful support assistant for Apicurio Registry, a CNCF sandbox project.\n\nSupported artifact types: {{supported_artifact_types}}\n\nYou should help users with installation, configuration, and usage questions.\n{{additional_context}}",
    "variables": {
      "supported_artifact_types": {"type": "string", "default": "AVRO, PROTOBUF, JSON, OPENAPI, ASYNCAPI"},
      "additional_context": {"type": "string", "default": ""}
    }
  }'
echo ""

# Enable BACKWARD compatibility
curl -s -X POST "$REGISTRY_URL/apis/registry/v3/groups/prompts/artifacts/support-system-prompt/rules" \
  -H "Content-Type: application/json" \
  -d '{"ruleType": "COMPATIBILITY", "config": "BACKWARD"}'
echo "System prompt v1 registered with BACKWARD compatibility"
echo ""

echo "--- Chat Prompt ---"
curl -s -X POST "$REGISTRY_URL/apis/registry/v3/groups/prompts/artifacts" \
  -H "Content-Type: application/json" \
  -H "X-Registry-ArtifactId: support-chat-prompt" \
  -H "X-Registry-ArtifactType: JSON" \
  -d '{
    "template": "{{system_prompt}}\n\nRelevant documentation:\n{{rag_context}}\n\nConversation history:\n{{conversation_history}}\n\nUser question: {{question}}",
    "variables": {
      "system_prompt": {"type": "string", "required": true},
      "rag_context": {"type": "string", "default": ""},
      "conversation_history": {"type": "string", "default": ""},
      "question": {"type": "string", "required": true}
    }
  }'
echo ""
echo "Chat prompt registered"
echo ""

echo "=== 2 prompt templates registered in group 'prompts' ==="
