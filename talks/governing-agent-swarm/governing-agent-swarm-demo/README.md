# Governing the Agent Swarm — Demo

Self-contained demo for the "Governing the Agent Swarm" talk. Uses Apicurio Registry to demonstrate agent discovery, communication contracts, and model metadata governance.

## Quick Start

```bash
docker compose up -d
# Wait for registry to be healthy
until curl -s http://localhost:8080/health | grep -q '"status":"UP"'; do sleep 2; done

# Run the full demo
./scripts/run-demo.sh
```

## Scripts

| Script | Purpose |
|--------|---------|
| `01-register-agents.sh` | Register 3 A2A Agent Cards for discovery |
| `02-register-contracts.sh` | Define request/response schemas with BACKWARD compatibility |
| `03-register-model-schema.sh` | Register model metadata schema + validate a model |
| `04-agent-versioning.sh` | Evolve an agent's capabilities (v2.1.0 → v3.0.0) |
| `05-discover-agents.sh` | Query the registry for agent discovery |
| `run-demo.sh` | Run all steps end-to-end with pauses |

## Components

- **Apicurio Registry 3.2.0** — stores agent cards, contracts, and model schemas
- For model metadata validation service, see the [model-metadata](../model-metadata/) cloned project
