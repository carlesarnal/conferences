# Talk repositories

All working repositories live beside their description. Existing repos use `talk/evidence-2026-10-23`; new repos use `main`.

All eleven repositories were pushed October 23, 2026. Follow the branch above in
existing repositories: default branches were not replaced. Each package includes
an abstract, evidence/verification ledger and presentation guidance. The agent
package retains its polished Paris deck and adds a future-CFP guide.

| Topic | Local path | GitHub |
|---|---|---|
| `kafka-proxy-schema-validation` | `talks/kafka-proxy-schema-validation/kroxylicious-schema-validation` | https://github.com/carlesarnal/kroxylicious-schema-validation |
| `database-to-lakehouse-realtime` | `talks/database-to-lakehouse-realtime/database-to-lakehouse-demo` | https://github.com/carlesarnal/database-to-lakehouse-demo |
| `agent-discovery` | `talks/agent-discovery/agent-discovery-demo` | https://github.com/carlesarnal/agent-discovery-demo |
| `governing-agent-swarm` | `talks/governing-agent-swarm/a2a-mcp-comparison` | https://github.com/carlesarnal/a2a-mcp-comparison |
| `security` | `talks/security/keycloak-strimzi-apicurio-security` | https://github.com/carlesarnal/keycloak-strimzi-apicurio-security |
| `data-contracts-ai-pipelines` | `talks/data-contracts-ai-pipelines/data-contracts-ai-demo` | https://github.com/carlesarnal/data-contracts-ai-demo |
| `prompt-templates-as-artifacts` | `talks/prompt-templates-as-artifacts/apicurio-registry-support-chat` | https://github.com/carlesarnal/apicurio-registry-support-chat |
| `stream-prediction` | `talks/stream-prediction/reddit-realtime-classification` | https://github.com/carlesarnal/reddit-realtime-classification |
| `edge-cloud` | `talks/edge-cloud/debezium-ocp-etc-demo` | https://github.com/carlesarnal/debezium-ocp-etc-demo |
| `cncf-sandbox-journey` | `talks/cncf-sandbox-journey/cncf-sandbox-journey` | https://github.com/carlesarnal/cncf-sandbox-journey |
| `oss-maintenance` | `talks/oss-maintenance/oss-maintainer-playbook` | https://github.com/carlesarnal/oss-maintainer-playbook |

## Blog drafts

Eleven posts, all `published: false`, are on:
https://github.com/Apicurio/apicurio.github.io/tree/blog/talk-evidence-series/_posts

Local website worktree: `/Users/carlesarnal/IdeaProjects/apicurio-blog-talks`.
The normal website checkout's rebranding branch was preserved.

## Verification and remaining work

- Proxy: real Compose integration passed locally and in GitHub Actions with broker
  assertions for six cases. CI run: https://github.com/carlesarnal/kroxylicious-schema-validation/actions/runs/39972012976
- Data contracts: real Registry rejection/preservation check and three semantic
  tests passed locally; GitHub Actions also passed.
- Agent discovery: retains the previously recorded nine tests/live smoke; not
  rerun during packaging.
- Prompts: three deterministic selection/cache tests passed; the real Java
  consumer, Registry integration and LLM evaluation remain unverified.
- Streaming: three timestamp-analyzer tests passed; no new load measurements.
- Search: three replay-model tests passed; no full snapshot/alias integration run.
- Security/lakehouse: Kubernetes API at the selected local context was unavailable.
  Configurations are not claimed freshly verified. Security remains incomplete.
- A2A/MCP: evidence-table validation passed, but the paired implementation is not
  complete; `--require-observed` deliberately fails until observations exist.
- Community talks: public-record exercises prepared; no causal growth claim.
- Ten new offline decks passed browser navigation, deep-link, notes and
  horizontal-layout checks at 1280x720 and 390x844. They are draft presentations,
  not a verified five-star live delivery.
- Website built successfully with `jekyll build --unpublished` in Ruby 2.7.8,
  Bundler 2.1.4 and the existing lockfile.

The repositories are independently versioned and ignored by the parent repo.
The parent no longer tracks copied files inside the security/agent checkouts.
Removing a nested checkout does not remove its GitHub repository.
