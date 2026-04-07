# Prompt Engineering Meets Schema Registry — Demo Walkthrough

This walkthrough accompanies the **prompt-templates-as-artifacts** talk. It demonstrates how to treat prompt templates as first-class registry artifacts in Apicurio Registry, using a RAG-powered support chatbot as the case study.

The demo code lives in the [apicurio-registry-support-chat](apicurio-registry-support-chat/) directory.

## Architecture

```
┌──────────┐    POST /support/chat     ┌────────────────────┐
│  Browser │──────────────────────────►│  Support Chat App  │
│  (UI)    │◄──────────────────────────│  (Quarkus)         │
└──────────┘    Chat response          │                    │
                                       │  ┌──────────────┐  │
                                       │  │ LangChain4j  │  │
                                       │  └──────┬───────┘  │
                                       └─────────┼──────────┘
                                                  │
                              ┌────────────────┬──┴──────────────┐
                              ▼                ▼                  ▼
                     ┌──────────────┐  ┌─────────────┐  ┌──────────────┐
                     │   Apicurio   │  │   Ollama    │  │  RAG Store   │
                     │   Registry   │  │   (LLM)    │  │  (Embeddings)│
                     │              │  │            │  │              │
                     │ PROMPT_      │  │ llama3.2   │  │ Apicurio     │
                     │ TEMPLATE     │  │            │  │ docs         │
                     │ artifacts    │  │ nomic-     │  │ (12 pages)   │
                     │              │  │ embed-text │  │              │
                     └──────────────┘  └────────────┘  └──────────────┘
```

## Prerequisites

1. Docker and Docker Compose
2. Java 21+ and Maven (or use Docker Compose for everything)
3. ~8GB RAM available (for Ollama LLM)


## Step 1: Start the Full Stack

The easiest way to run the demo is with Docker Compose:

```bash
cd apicurio-registry-support-chat

# Build the application
mvn package -DskipTests

# Start everything: Apicurio Registry + Ollama + Support Chat
docker compose up -d
```

This starts:
- **Apicurio Registry** on http://localhost:8080
- **Ollama** on http://localhost:11434 (with llama3.2 and nomic-embed-text models)
- **Support Chat** on http://localhost:8081

Wait for all services to be healthy:
```bash
docker compose ps
```

**Demo point:** Three containers — the registry for prompt governance, Ollama for local LLM inference, and the Quarkus app tying them together.


## Step 2: Create Prompt Templates in the Registry

Run the initialization script to register prompt templates as PROMPT_TEMPLATE artifacts:

```bash
./scripts/create-prompts.sh
```

This creates two artifacts in Apicurio Registry:
- `apicurio-support-system-prompt` — defines the assistant's role, capabilities, and behavior
- `apicurio-support-chat-prompt` — structures each user interaction with conversation history and RAG context

**Demo point:** Open the Registry UI at http://localhost:8080 and browse to these artifacts. Show that prompt templates are stored alongside traditional schemas (Avro, Protobuf, OpenAPI) — same governance model, new artifact type.


## Step 3: Explore the Prompt Template Structure

```bash
# Fetch the system prompt template
curl -s "http://localhost:8080/apis/registry/v3/groups/default/artifacts/apicurio-support-system-prompt/versions/1/content" | jq
```

Key elements to highlight:
- **Template text** with `{{variable}}` placeholders (e.g., `{{supported_artifact_types}}`)
- **Variable definitions** with types and defaults
- **Version metadata** — this is version 1 of the prompt

```bash
# Fetch the chat prompt template
curl -s "http://localhost:8080/apis/registry/v3/groups/default/artifacts/apicurio-support-chat-prompt/versions/1/content" | jq
```

Variables in the chat prompt:
- `{{system_prompt}}` — rendered system prompt + RAG documentation
- `{{question}}` — current user question
- `{{conversation_history}}` — previous turns in the session
- `{{include_examples}}` — toggle for code examples

**Demo point:** The prompt template is not a static string — it's a structured artifact with typed variables, just like a schema has typed fields.


## Step 4: Chat with the Support Bot

Open http://localhost:8081 in your browser. The web UI shows:
- Status indicators for Registry, RAG, and LLM connectivity
- A chat interface with session management

Ask a question:
> "How do I install Apicurio Registry using Docker?"

**Demo point:** Walk through what happens behind the scenes:
1. The app fetches the system prompt from Apicurio Registry (version 1)
2. RAG retrieves relevant documentation snippets from the embedded docs
3. The chat prompt template is rendered with the question, conversation history, and RAG context
4. The rendered prompt is sent to Ollama (llama3.2)
5. The response is stored in the conversation memory for context continuity


## Step 5: Preview Rendered Prompts (Without LLM)

Show what the LLM actually sees:

```bash
# Create a session
SESSION_ID=$(curl -s -X POST http://localhost:8081/support/session | jq -r '.sessionId')

# Preview the rendered prompt without calling the LLM
curl -s -X POST "http://localhost:8081/support/prompts/preview" \
  -H "Content-Type: application/json" \
  -d "{\"sessionId\": \"$SESSION_ID\", \"question\": \"How do I configure schema validation rules?\"}" | jq
```

**Demo point:** This is the key debugging feature. You can see exactly what the LLM receives — the rendered system prompt, the RAG-retrieved documentation, and the formatted question. When a prompt change causes unexpected behavior, this endpoint lets you inspect the actual input.


## Step 6: Demonstrate Prompt Versioning

This is the core of the talk — show what happens when you update a prompt template:

```bash
# Current version works well
curl -s -X POST "http://localhost:8081/support/chat/$SESSION_ID" \
  -H "Content-Type: application/json" \
  -d '{"message": "What artifact types does Apicurio support?"}' | jq '.answer'

# Create a new version of the system prompt (version 2)
# Add a constraint: responses must include code examples
curl -X POST "http://localhost:8080/apis/registry/v3/groups/default/artifacts/apicurio-support-system-prompt/versions" \
  -H "Content-Type: application/json" \
  -d '{
    "template": "You are a helpful support assistant for Apicurio Registry. Always include code examples in your responses.\n\nSupported artifact types: {{supported_artifact_types}}\n{{additional_context}}",
    "variables": {
      "supported_artifact_types": {"type": "string", "default": "AVRO, PROTOBUF, JSON, OPENAPI, ASYNCAPI, PROMPT_TEMPLATE, MODEL_SCHEMA"},
      "additional_context": {"type": "string", "default": ""}
    }
  }'

# Ask the same question with the new prompt version
curl -s -X POST "http://localhost:8081/support/chat/$SESSION_ID?systemPromptVersion=2" \
  -H "Content-Type: application/json" \
  -d '{"message": "What artifact types does Apicurio support?"}' | jq '.answer'
```

**Demo point:** The response now includes code examples because version 2 of the prompt instructs the LLM to do so. The key insight: **you changed the application's behavior by updating a registry artifact, not by redeploying code**. Version 1 is still available for other consumers that haven't migrated.


## Step 7: Search Model Schemas

Show the MODEL_SCHEMA artifact type for AI model discovery:

```bash
# Search for models by capability
curl -s "http://localhost:8081/support/models?capability=chat" | jq

# Search by provider
curl -s "http://localhost:8081/support/models?provider=anthropic" | jq

# Search by context window
curl -s "http://localhost:8081/support/models?minContextWindow=100000" | jq
```

**Demo point:** The registry isn't just for prompts — it also stores MODEL_SCHEMA artifacts that describe AI model capabilities. This enables model discovery and selection based on requirements.


## Key Talking Points

1. **Prompts are artifacts** — Prompt templates deserve the same governance as API schemas: versioning, compatibility rules, and access control. Apicurio Registry provides all of this out of the box.
2. **Variable substitution** — Prompt templates use `{{variables}}` with typed definitions. The registry validates that required variables are provided and types match.
3. **Version-controlled behavior** — Changing a prompt version changes application behavior without redeployment. Teams can A/B test prompts by routing traffic to different versions.
4. **RAG + prompt governance** — The RAG pipeline retrieves documentation, but the prompt template controls how that documentation is presented to the LLM. Both layers matter.
5. **When it's overkill** — A single-developer prototype doesn't need prompt governance. This pattern pays off when multiple teams share prompts, when prompt changes have caused production incidents, or when you need audit trails for compliance.
