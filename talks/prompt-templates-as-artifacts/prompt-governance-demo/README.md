# Prompt Engineering Meets Schema Registry — Demo

Self-contained demo for the "Prompt Templates as Artifacts" talk. Uses Apicurio Registry to demonstrate prompt template governance, versioning, and rendering.

## Quick Start

```bash
docker compose up -d
# Wait for registry to be healthy
until curl -s http://localhost:8080/health | grep -q '"status":"UP"'; do sleep 2; done

# Run the full demo
./scripts/run-demo.sh
```

For the full RAG chatbot demo with LLM integration, see [apicurio-registry-support-chat](../apicurio-registry-support-chat/).

## Scripts

| Script | Purpose |
|--------|---------|
| `01-register-prompts.sh` | Register system and chat prompt templates with BACKWARD compat |
| `02-version-prompt.sh` | Create v2 of system prompt (adds code examples requirement) |
| `03-render-prompt.sh` | Show how templates are rendered with variable substitution |
| `run-demo.sh` | Run all steps end-to-end with pauses |

## Components

- **Apicurio Registry 3.2.0** — stores PROMPT_TEMPLATE artifacts with versioning and compatibility rules
