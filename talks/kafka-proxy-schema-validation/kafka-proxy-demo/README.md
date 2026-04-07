# Transparent Schema Validation at the Kafka Proxy Layer — Demo

Self-contained demo for the "Kafka Proxy Schema Validation" talk. Uses Kafka, Apicurio Registry, and Kroxylicious to demonstrate transparent schema validation.

## Quick Start

```bash
# Start Kafka and Apicurio Registry
docker compose up -d

# Build Kroxylicious (from cloned project)
cd ../kroxylicious-schema-validation && mvn verify && cd -

# Start the proxy
java -jar ../kroxylicious-schema-validation/target/kroxylicious-schema-validation-*.jar \
  --config proxy-config.yaml

# In another terminal, run the demo
./scripts/run-demo.sh
```

## Scripts

| Script | Purpose |
|--------|---------|
| `01-register-schema.sh` | Register JSON Schema for orders topic with FULL validity |
| `02-create-topic.sh` | Create the orders topic in Kafka |
| `03-produce-valid.sh` | Send valid messages through proxy (accepted) |
| `04-produce-invalid.sh` | Send invalid messages through proxy (rejected) |
| `05-verify-kafka.sh` | Verify only valid messages reached Kafka |
| `run-demo.sh` | Run all steps end-to-end with pauses |

## Components

- **Kafka 3.9** (Bitnami, KRaft mode)
- **Apicurio Registry 3.2.0** — schema storage and validation
- **Kroxylicious** — Kafka proxy with schema validation filter (from [kroxylicious-schema-validation](../kroxylicious-schema-validation/))
