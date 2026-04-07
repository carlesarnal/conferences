# Agent Discovery Demo

Demonstrates AI agent discovery, prompt template governance, and model schema validation using Apicurio Registry (CNCF sandbox).

## Quick Start

```bash
# Start Apicurio Registry
docker compose up -d

# Run the full demo
./scripts/run-demo.sh
```

## What It Does

1. **Registers A2A Agent Cards** — Three agents (Summarizer, Translator, Data Enrichment) with capabilities and skills
2. **Registers Prompt Templates** — Version-controlled prompts with BACKWARD compatibility rules
3. **Registers Model Schemas** — JSON Schema for ML model metadata with validation
4. **Demonstrates Discovery** — Queries the registry to find agents, compare prompt versions, retrieve model metadata

## Scripts

| Script | Purpose |
|---|---|
| `01-register-agents.sh` | Register 3 A2A Agent Cards |
| `02-register-prompts.sh` | Register prompt templates with versioning |
| `03-register-model-schemas.sh` | Register model metadata schema + sample model |
| `04-discover-agents.sh` | Query the registry for discovery |
| `run-demo.sh` | Run all steps end-to-end |

## Registry UI

After starting, open http://localhost:8080 to browse:
- `ai-agents` group — Agent Cards
- `prompts` group — Prompt Templates
- `model-schemas` group — Model Metadata
