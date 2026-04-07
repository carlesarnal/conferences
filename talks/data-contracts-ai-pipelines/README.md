# Data Contracts for Event-Driven AI — Demo Walkthrough

This walkthrough accompanies the **data-contracts-ai-pipelines** talk. It demonstrates how schema registries enforce data contracts in AI pipelines, preventing silent schema changes from breaking downstream ML inference.

The demo reuses infrastructure patterns from the [debezium-ocp-etc-demo](debezium-ocp-etc-demo/) project.

## Architecture

```
┌────────────┐     CDC      ┌─────────┐   Avro (schema   ┌──────────────┐   Predictions   ┌────────────┐
│ PostgreSQL │──Debezium───►│  Kafka  │───enforced)──────►│ ML Inference │───────────────►│  Consumer  │
│ (source)   │              │(Strimzi)│                   │  Service     │                │  (API)     │
└────────────┘              └────┬────┘                   └──────────────┘                └────────────┘
                                 │
                          ┌──────┴──────┐
                          │  Apicurio   │
                          │  Registry   │
                          │             │
                          │ Data        │
                          │ Contracts:  │
                          │ - Input     │
                          │   schema    │
                          │ - Output    │
                          │   schema    │
                          │ - BACKWARD  │
                          │   compat    │
                          └─────────────┘
```

## Prerequisites

1. A Kubernetes cluster (Minikube, Kind, or OpenShift)
2. [Strimzi Operator](https://strimzi.io/quickstarts/) installed
3. `kubectl` configured


## Step 1: Deploy the Infrastructure

Follow the installation steps in the [debezium-ocp-etc-demo README](debezium-ocp-etc-demo/README.md) to deploy:
- Apache Kafka (Strimzi)
- Apicurio Registry
- PostgreSQL
- Kafka Connect with Debezium

```bash
kubectl create namespace data-contracts

# Deploy Kafka, Registry, PostgreSQL, and Kafka Connect
# (refer to debezium-ocp-etc-demo/README.md for detailed steps)
```


## Step 2: Define the Data Contract (Input Schema)

Register the input schema — this is the **data contract** between the CDC producer and downstream consumers:

```bash
kubectl port-forward svc/apicurio-registry 8080:8080 -n data-contracts &

# Register the CDC event schema with BACKWARD compatibility
curl -X POST "http://localhost:8080/apis/registry/v3/groups/data-contracts/artifacts" \
  -H "Content-Type: application/json" \
  -H "X-Registry-ArtifactId: customer-events-value" \
  -H "X-Registry-ArtifactType: AVRO" \
  -d '{
    "type": "record",
    "name": "CustomerEvent",
    "namespace": "io.apicurio.demo",
    "fields": [
      {"name": "id", "type": "int"},
      {"name": "first_name", "type": "string"},
      {"name": "last_name", "type": "string"},
      {"name": "email", "type": "string"}
    ]
  }'

# Enforce BACKWARD compatibility — new versions must not break existing consumers
curl -X POST "http://localhost:8080/apis/registry/v3/groups/data-contracts/artifacts/customer-events-value/rules" \
  -H "Content-Type: application/json" \
  -d '{"ruleType": "COMPATIBILITY", "config": "BACKWARD"}'

echo "Data contract registered with BACKWARD compatibility"
```

**Demo point:** Open the Registry UI and show the schema. This is the data contract — the CDC producer (Debezium) serializes events using this Avro schema, and downstream consumers (including ML services) depend on it. The BACKWARD rule means new versions can add fields with defaults but cannot remove or rename existing fields.


## Step 3: Define the Output Contract (Predictions Schema)

Register the schema for the ML inference output:

```bash
curl -X POST "http://localhost:8080/apis/registry/v3/groups/data-contracts/artifacts" \
  -H "Content-Type: application/json" \
  -H "X-Registry-ArtifactId: predictions-value" \
  -H "X-Registry-ArtifactType: AVRO" \
  -d '{
    "type": "record",
    "name": "Prediction",
    "namespace": "io.apicurio.demo",
    "fields": [
      {"name": "customer_id", "type": "int"},
      {"name": "prediction", "type": "string"},
      {"name": "confidence", "type": "double"},
      {"name": "model_version", "type": "string"},
      {"name": "timestamp", "type": "long"}
    ]
  }'

curl -X POST "http://localhost:8080/apis/registry/v3/groups/data-contracts/artifacts/predictions-value/rules" \
  -H "Content-Type: application/json" \
  -d '{"ruleType": "COMPATIBILITY", "config": "BACKWARD"}'
```

**Demo point:** Now there are two data contracts — one for the input (CDC events) and one for the output (predictions). Both are governed by the same registry with the same compatibility rules.


## Step 4: Show the CDC Pipeline in Action

Deploy the Debezium source connector (from the debezium-ocp-etc-demo):

```bash
# Apply the PostgreSQL connector
kubectl apply -f debezium-ocp-etc-demo/connectors/source-postgres-connector.yaml -n data-contracts
```

Insert data into PostgreSQL:
```bash
kubectl exec -it postgres -n data-contracts -- psql --user postgres -c \
  "INSERT INTO inventory.customers VALUES (1005, 'Alice', 'Smith', 'alice@example.com');"
```

**Demo point:** Show the CDC event in Kafka (via Kafka UI or console consumer). The event is serialized in Avro using the registered schema. The schema ID is embedded in the message header — any consumer can look up the schema from the registry to deserialize.


## Step 5: Demonstrate a Compatible Schema Change

```bash
# Add an optional field (compatible change)
curl -X POST "http://localhost:8080/apis/registry/v3/groups/data-contracts/artifacts/customer-events-value/versions" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "record",
    "name": "CustomerEvent",
    "namespace": "io.apicurio.demo",
    "fields": [
      {"name": "id", "type": "int"},
      {"name": "first_name", "type": "string"},
      {"name": "last_name", "type": "string"},
      {"name": "email", "type": "string"},
      {"name": "segment", "type": ["null", "string"], "default": null}
    ]
  }'

echo "Version 2 registered — added optional 'segment' field"
```

**Demo point:** This succeeds because adding a nullable field with a default is backward compatible. Existing consumers continue to work — they simply ignore the new field. New consumers can use it for ML feature enrichment.


## Step 6: Demonstrate a Breaking Schema Change

```bash
# Try to remove a required field (breaking change)
curl -s -X POST "http://localhost:8080/apis/registry/v3/groups/data-contracts/artifacts/customer-events-value/versions" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "record",
    "name": "CustomerEvent",
    "namespace": "io.apicurio.demo",
    "fields": [
      {"name": "id", "type": "int"},
      {"name": "full_name", "type": "string"},
      {"name": "email", "type": "string"}
    ]
  }'
```

**Demo point:** This **fails** — the registry rejects it because removing `first_name` and `last_name` and adding `full_name` breaks backward compatibility. The ML inference service that depends on `first_name` would crash. **The data contract prevented a production incident.**


## Key Talking Points

1. **Data contracts = schema + compatibility rules** — A schema alone is documentation. A schema with BACKWARD compatibility enforced at the registry level is a contract.
2. **Contract at produce time, not prediction time** — Schema validation happens when the event is serialized. A breaking change is caught before it enters Kafka, not when the ML model fails at 3 AM.
3. **CDC as the golden source** — Debezium captures the exact database state. The Avro schema in the registry ensures that capture is type-safe and versioned.
4. **Avro vs Protobuf vs JSON Schema** — Discuss when each fits AI workloads. Avro for compact binary (high-throughput CDC), Protobuf for cross-language ML services, JSON Schema for human-readable metadata.
5. **45% of AI projects fail on data quality** — The root cause is often silent schema drift between producers and consumers. Data contracts prevent this class of failures.
