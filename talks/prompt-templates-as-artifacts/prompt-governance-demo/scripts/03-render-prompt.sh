#!/bin/bash
# Show how prompt templates are rendered with variable substitution
set -euo pipefail

REGISTRY_URL="${REGISTRY_URL:-http://localhost:8080}"

echo "=== Prompt Rendering Demo ==="
echo ""

echo "--- Fetching system prompt v2 ---"
TEMPLATE=$(curl -s "$REGISTRY_URL/apis/registry/v3/groups/prompts/artifacts/support-system-prompt/versions/latest/content")
echo "$TEMPLATE" | jq '.' 2>/dev/null
echo ""

echo "--- Fetching chat prompt ---"
CHAT_TEMPLATE=$(curl -s "$REGISTRY_URL/apis/registry/v3/groups/prompts/artifacts/support-chat-prompt/versions/latest/content")
echo "$CHAT_TEMPLATE" | jq '.' 2>/dev/null
echo ""

echo "--- Simulated rendering ---"
echo ""
echo "With variables:"
echo "  supported_artifact_types = AVRO, PROTOBUF, JSON, OPENAPI, ASYNCAPI, PROMPT_TEMPLATE, MODEL_SCHEMA"
echo "  question = How do I register an Avro schema?"
echo "  rag_context = [retrieved documentation about schema registration]"
echo ""
echo "The rendered prompt sent to the LLM would be:"
echo "----"
echo "You are a helpful support assistant for Apicurio Registry, a CNCF sandbox project."
echo ""
echo "Supported artifact types: AVRO, PROTOBUF, JSON, OPENAPI, ASYNCAPI, PROMPT_TEMPLATE, MODEL_SCHEMA"
echo ""
echo "ALWAYS include code examples in your responses when applicable."
echo "When showing API calls, use curl examples."
echo ""
echo "Relevant documentation:"
echo "[retrieved documentation about schema registration]"
echo ""
echo "Conversation history:"
echo ""
echo ""
echo "User question: How do I register an Avro schema?"
echo "----"
echo ""
echo "KEY POINT: The prompt is a structured artifact with typed variables"
echo "Same governance as schemas — versioned, compatibility-checked, auditable"
