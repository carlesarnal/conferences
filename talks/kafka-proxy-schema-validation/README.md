# Transparent Schema Validation at the Kafka Proxy Layer — Demo Walkthrough

This walkthrough accompanies the **kafka-proxy-schema-validation** talk. It demonstrates how to enforce schema validation at the Kafka proxy layer using Kroxylicious, without modifying producer code.

The demo code lives in the [kroxylicious-schema-validation](kroxylicious-schema-validation/) directory.

## Architecture

```
                                  Kroxylicious Proxy
                              ┌────────────────────────┐
Producer ──► Produce Request ──►│  ProduceRequestFilter  │──► Kafka Broker
(unmodified)                   │         │               │
                               │    Validate payload     │
                               │    against schema       │
                               │         │               │
                               │         ▼               │
                               │  ┌──────────────┐      │
                               │  │   Apicurio   │      │
                               │  │   Registry   │      │
                               │  └──────────────┘      │
                               └────────────────────────┘
                                        │
                               Invalid? ──► REJECT (error to producer)
                               Valid?   ──► FORWARD to broker
```

## Prerequisites

1. Java 17+ and Maven
2. Docker (for Kafka and Apicurio Registry)
3. `curl` and `jq`


## Step 1: Start Infrastructure

```bash
# Start Kafka (using KRaft mode)
docker run -d --name kafka \
  -p 9092:9092 \
  -e KAFKA_CFG_NODE_ID=0 \
  -e KAFKA_CFG_PROCESS_ROLES=controller,broker \
  -e KAFKA_CFG_CONTROLLER_QUORUM_VOTERS=0@localhost:9093 \
  -e KAFKA_CFG_LISTENERS=PLAINTEXT://:9092,CONTROLLER://:9093 \
  -e KAFKA_CFG_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092 \
  -e KAFKA_CFG_CONTROLLER_LISTENER_NAMES=CONTROLLER \
  -e KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT \
  bitnami/kafka:3.9

# Start Apicurio Registry
docker run -d --name apicurio-registry \
  -p 8080:8080 \
  apicurio/apicurio-registry:3.0.6

# Wait for services
until curl -s http://localhost:8080/health | grep -q '"status":"UP"'; do sleep 2; done
echo "Infrastructure ready"
```


## Step 2: Register a Schema

Register a JSON Schema for the topic we'll validate against:

```bash
# Register a schema for "orders" topic
curl -X POST "http://localhost:8080/apis/registry/v3/groups/default/artifacts" \
  -H "Content-Type: application/json" \
  -H "X-Registry-ArtifactId: orders-value" \
  -H "X-Registry-ArtifactType: JSON" \
  -d '{
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "title": "Order",
    "type": "object",
    "required": ["orderId", "customerId", "amount", "currency"],
    "properties": {
      "orderId": {"type": "string"},
      "customerId": {"type": "string"},
      "amount": {"type": "number", "minimum": 0},
      "currency": {"type": "string", "enum": ["USD", "EUR", "GBP"]}
    },
    "additionalProperties": false
  }'

# Enable BACKWARD compatibility
curl -X POST "http://localhost:8080/apis/registry/v3/groups/default/artifacts/orders-value/rules" \
  -H "Content-Type: application/json" \
  -d '{"ruleType": "VALIDITY", "config": "FULL"}'

echo "Schema registered with FULL validity enforcement"
```

**Demo point:** Open the Registry UI at http://localhost:8080 and show the schema. This defines the contract: every order must have orderId, customerId, amount (positive number), and currency (USD/EUR/GBP).


## Step 3: Build and Configure Kroxylicious

```bash
cd kroxylicious-schema-validation
mvn verify
cd ..
```

Create the proxy configuration:

```bash
cat > proxy-config.yaml <<'EOF'
virtualClusters:
  demo:
    targetCluster:
      bootstrap_servers: localhost:9092
    clusterNetworkAddressConfigProvider:
      type: PortPerBrokerClusterNetworkAddressConfigProvider
      config:
        bootstrapAddress: localhost:19092
    filters:
      - type: SampleProduceRequestFilterFactory
        config:
          registryUrl: http://localhost:8080/apis/registry/v3
          groupId: default
EOF
```

Start the proxy:
```bash
java -jar kroxylicious-schema-validation/target/kroxylicious-schema-validation-*.jar \
  --config proxy-config.yaml
```

The proxy listens on `localhost:19092` and forwards validated traffic to Kafka on `localhost:9092`.


## Step 4: Create the Topic

```bash
docker exec kafka kafka-topics.sh \
  --create --topic orders \
  --bootstrap-server localhost:9092 \
  --partitions 3 --replication-factor 1
```


## Using the Demo

### Produce a Valid Message (Through Proxy)

```bash
# Produce through the Kroxylicious proxy (port 19092)
echo '{"orderId":"ORD-001","customerId":"CUST-42","amount":99.95,"currency":"EUR"}' | \
  docker exec -i kafka kafka-console-producer.sh \
    --bootstrap-server localhost:19092 \
    --topic orders
```

**Demo point:** The message passes through Kroxylicious, gets validated against the schema in Apicurio Registry, and is forwarded to Kafka. The producer doesn't know the proxy exists.

### Produce an Invalid Message (Through Proxy)

```bash
# Missing required field "currency"
echo '{"orderId":"ORD-002","customerId":"CUST-42","amount":50.00}' | \
  docker exec -i kafka kafka-console-producer.sh \
    --bootstrap-server localhost:19092 \
    --topic orders

# Invalid type: amount is a string instead of number
echo '{"orderId":"ORD-003","customerId":"CUST-42","amount":"free","currency":"USD"}' | \
  docker exec -i kafka kafka-console-producer.sh \
    --bootstrap-server localhost:19092 \
    --topic orders

# Invalid enum value for currency
echo '{"orderId":"ORD-004","customerId":"CUST-42","amount":25.00,"currency":"BTC"}' | \
  docker exec -i kafka kafka-console-producer.sh \
    --bootstrap-server localhost:19092 \
    --topic orders
```

**Demo point:** All three messages are **rejected by the proxy** before reaching Kafka. The producer receives an error. Show the Kroxylicious logs to see the validation errors:
- Missing required property: `currency`
- Type mismatch: `amount` expected number, got string
- Enum violation: `BTC` not in `[USD, EUR, GBP]`

### Verify Only Valid Messages Reached Kafka

```bash
docker exec kafka kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic orders \
  --from-beginning
```

**Demo point:** Only `ORD-001` appears. The invalid messages never reached the broker. This is the key value: **data quality enforced at the infrastructure layer**, not dependent on producer discipline.

### Produce Directly to Kafka (Bypass Proxy)

```bash
# Produce directly to Kafka (port 9092, not 19092) — bypasses validation
echo '{"garbage": true}' | \
  docker exec -i kafka kafka-console-producer.sh \
    --bootstrap-server localhost:9092 \
    --topic orders
```

**Demo point:** This bypasses the proxy and reaches Kafka unvalidated. Discuss when to combine proxy-layer validation with client-side validation, and how network policies can ensure all traffic flows through the proxy.


## Key Talking Points

1. **Transparent enforcement** — Producers connect to the proxy instead of Kafka directly. No SDK changes, no code modifications. The proxy validates and forwards.
2. **Legacy producer support** — This is the only way to enforce schema validation on producers you can't modify: third-party integrations, legacy applications, different language runtimes.
3. **Centralized vs. client-side** — Client-side validation (Kafka serializers + registry) is the standard approach. Proxy-layer validation complements it for scenarios where client-side enforcement isn't possible.
4. **Performance considerations** — The proxy adds latency per message (schema fetch + validation). Discuss caching strategies and when the tradeoff is worth it.
5. **Apicurio Registry as the source of truth** — Both client-side serializers and the Kroxylicious filter fetch schemas from the same Apicurio Registry instance. One schema, enforced at multiple layers.
