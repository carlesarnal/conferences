# Conference Talks

Personal knowledge base tracking my conference talk abstracts and acceptances as a Principal Software Engineer in the Apicurio community (CNCF sandbox project).

## Structure

- **`talks/`** — Talk abstracts and walkthrough demos organized by topic. Each talk directory contains the abstract (`description.txt` or named `.txt`), a demo walkthrough (`README.md`), and optionally the cloned demo project.
- **`conferences/`** — Accepted conferences, linking each to its talk and demo project.

## 2027 Planning

- [2027 conference priorities](conferences/2027-summary.txt) — ranked options, verified deadlines, submitted events, and Japan/Australia watchlist.
- [CFP tracker](conferences/cfp-tracker.md) — detailed status and discovery inventory.

## Talks

Abstracts: `talks/<topic>/description.txt`. Scores and status: [talks/REVIEW.txt](talks/REVIEW.txt).

| Topic | Title | Demo | Demo status |
|---|---|---|---|
| `kafka-proxy-schema-validation` | Validate Before Kafka: What Happens When a Proxy Enforces Your Schemas | `talks/kafka-proxy-schema-validation/kafka-proxy-demo` | verified Sep 2026 |
| `database-to-lakehouse-realtime` | The Sink Said RUNNING: Building a CDC-to-Iceberg Pipeline on Kubernetes, Honestly | `talks/database-to-lakehouse-realtime` | verified Sep 2026 |
| `agent-discovery` | Agent Sprawl Is the New Microservice Sprawl: Discovery and Lifecycle for Multi-Agent AI | [agent-discovery-demo](https://github.com/carlesarnal/agent-discovery-demo/tree/cloud-native-paris-2026) | verified Sep 2026 |
| `governing-agent-swarm` | A2A or MCP? Composing Agents and Tools Without Building a Distributed Monolith | same as agent-discovery | demo ready, comparison segment pending |
| `security` | One Keycloak Realm, Separate Trust Boundaries: Securing Kafka and Its Schema Registry | `talks/security` | not verified |
| `data-contracts-ai-pipelines` | Your Model Didn't Change, Your Input Did: Data Contracts for Streaming AI Pipelines | `talks/data-contracts-ai-pipelines` | not verified |
| `prompt-templates-as-artifacts` | Your Prompts Are Unversioned: Releasing and Rolling Back LLM Prompts Like Code | `talks/prompt-templates-as-artifacts/prompt-governance-demo` | not verified |
| `stream-prediction` | Classify It Before a Human Sees It: Operating Streaming ML Inference on Kubernetes | [reddit-realtime-classification](https://github.com/carlesarnal/reddit-realtime-classification) | not verified |
| `edge-cloud` | Keeping Search in Sync Without Glue Code: CDC from PostgreSQL to Elasticsearch on Kubernetes | [debezium-ocp-etc-demo](https://github.com/carlesarnal/debezium-ocp-etc-demo) | outdated (2024) |
| `cncf-sandbox-journey` | What the CNCF Sandbox Actually Asks For: Lessons from Bringing Apicurio Registry In | — (story talk) | needs specifics |
| `oss-maintenance` | Five Years Maintaining Apicurio Registry: What We Got Wrong About Contributors | — (story talk) | needs specifics |

## Conferences

| Conference | Year | Talk | Demo Project |
|---|---|---|---|
| Current | 2023 | `edge-cloud` | [debezium-ocp-etc-demo](https://github.com/carlesarnal/debezium-ocp-etc-demo) |
| OSS Japan | 2023 | `edge-cloud` | [debezium-ocp-etc-demo](https://github.com/carlesarnal/debezium-ocp-etc-demo) |
| DevConf US | 2024 | `oss-maintenance` | — |
| Data Saturday Oslo | 2024 | `edge-cloud` | [debezium-ocp-etc-demo](https://github.com/carlesarnal/debezium-ocp-etc-demo) |
| OCX | 2026 | `stream-prediction` | [reddit-realtime-classification](https://github.com/carlesarnal/reddit-realtime-classification) |
