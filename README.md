# Conference Talks

Personal knowledge base tracking my conference talk abstracts and acceptances as a Principal Software Engineer in the Apicurio community (CNCF sandbox project).

## Structure

- **`talks/`** — Talk abstracts and walkthrough demos organized by topic. Each talk directory contains the abstract (`description.txt` or named `.txt`), a demo walkthrough (`README.md`), and optionally the cloned demo project.
- **`conferences/`** — Accepted conferences, linking each to its talk and demo project.

## 2027 Planning

- [2027 conference priorities](conferences/2027-summary.txt) — ranked options, verified deadlines, submitted events, and Japan/Australia watchlist.
- [CFP tracker](conferences/cfp-tracker.md) — detailed status and discovery inventory.

## Talks

Local checkout paths, public repositories, branches and verification status:
[talks/REPOSITORIES.md](talks/REPOSITORIES.md). Each checkout is next to its abstract.
The eleven blog drafts are on the website's `blog/talk-evidence-series` branch.

Abstracts: `talks/<topic>/description.txt`. Editorial review and evidence status: [talks/REVIEW.txt](talks/REVIEW.txt). Preparation tasks and timed outlines: [talks/PREPARATION.txt](talks/PREPARATION.txt). Audience, community value and supporting-resource notes: [talks/CFP-PACKAGING.txt](talks/CFP-PACKAGING.txt). Inspected public contributions and firsthand records: [talks/EVIDENCE.txt](talks/EVIDENCE.txt).

| Topic | Title | Demo | Demo status |
|---|---|---|---|
| `kafka-proxy-schema-validation` | Validate Before Kafka: What Happens When a Proxy Enforces Your Schemas | `talks/kafka-proxy-schema-validation/kroxylicious-schema-validation` | six integration cases passed locally and in CI Oct 23 |
| `database-to-lakehouse-realtime` | The Sink Said RUNNING: Is Your CDC-to-Iceberg Pipeline Making Progress? | `talks/database-to-lakehouse-realtime` | base demo verified Sep 2026; progress checklist pending |
| `agent-discovery` | Agent Sprawl Is the New Microservice Sprawl: Discovery and Governance for Multi-Agent AI | [connected workflow](talks/agent-discovery/agent-discovery-demo/README.md) | pinned PR #2932 sample; tests and live smoke passed Oct 23 |
| `governing-agent-swarm` | A2A or MCP? Choosing an Interface for the Same Capability | `talks/governing-agent-swarm/a2a-mcp-comparison` | official SDK HTTP comparison passed |
| `security` | One Keycloak Realm, Separate Trust Boundaries: Securing Kafka and Its Schema Registry | `talks/security/keycloak-strimzi-apicurio-security` | real OAuth/ACL Compose checks passed |
| `data-contracts-ai-pipelines` | Your Model Didn't Change, Your Input Did: Data Contracts for Streaming AI Pipelines | `talks/data-contracts-ai-pipelines/data-contracts-ai-demo` | Registry and semantic checks passed locally and in CI Oct 23 |
| `prompt-templates-as-artifacts` | Beyond Git: Releasing and Rolling Back Runtime Prompt Templates | `talks/prompt-templates-as-artifacts/apicurio-registry-support-chat` | real Registry/Ollama run; candidate promotion correctly blocked |
| `stream-prediction` | Why Are Predictions Late? Diagnosing Streaming Inference on Kubernetes | [reddit-realtime-classification](https://github.com/carlesarnal/reddit-realtime-classification/tree/talk/evidence-2026-10-23) | real Spark isolation experiment measured; no K8s benchmark |
| `edge-cloud` | Rebuilding a Search Index While the Database Keeps Changing | [debezium-ocp-etc-demo](https://github.com/carlesarnal/debezium-ocp-etc-demo/tree/talk/evidence-2026-10-23) | real retained-history CDC and alias-cutover checks passed |
| `cncf-sandbox-journey` | Preparing a CNCF Sandbox Application: A Maintainer's View from Apicurio Registry | — (community talk) | public deferral/application/onboarding records inspected |
| `oss-maintenance` | Beyond the First Pull Request: Making Contribution Work Sustainable | — (community talk) | public workflow and reviewed PR inspected; hand-off trace to prepare |

## Conferences

| Conference | Year | Talk | Demo Project |
|---|---|---|---|
| Current | 2023 | `edge-cloud` | [debezium-ocp-etc-demo](https://github.com/carlesarnal/debezium-ocp-etc-demo) |
| OSS Japan | 2023 | `edge-cloud` | [debezium-ocp-etc-demo](https://github.com/carlesarnal/debezium-ocp-etc-demo) |
| DevConf US | 2024 | `oss-maintenance` | — |
| Data Saturday Oslo | 2024 | `edge-cloud` | [debezium-ocp-etc-demo](https://github.com/carlesarnal/debezium-ocp-etc-demo) |
| OCX | 2026 | `stream-prediction` | [reddit-realtime-classification](https://github.com/carlesarnal/reddit-realtime-classification) |
