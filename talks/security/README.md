# Securing the Data Platform with Keycloak, Strimzi, and Apicurio — Demo Walkthrough

This walkthrough accompanies the **security** talk. It demonstrates how to integrate Keycloak as a centralized identity provider with Strimzi (Kafka on Kubernetes) and Apicurio Registry to build a unified, zero-trust data platform.

## Architecture

```
Producers / Consumers
        │
        │ OAuth2 Bearer Token
        ▼
   ┌─────────┐     OAuth2 Token     ┌──────────┐
   │ Strimzi │◄────Validation──────►│ Keycloak │
   │ (Kafka) │                      │  (IdP)   │
   └────┬────┘                      └────┬─────┘
        │                                │
   Schema Fetch                    OIDC / OAuth2
        │                                │
        ▼                                ▼
   ┌───────────┐                  ┌────────────┐
   │ Apicurio  │◄───OAuth2───────│ Applications│
   │ Registry  │   Token Auth     └────────────┘
   └───────────┘
```

## Prerequisites

1. A Kubernetes cluster (Minikube, Kind, or OpenShift)
2. [Strimzi Operator](https://strimzi.io/quickstarts/) installed
3. `kubectl` and `helm` configured
4. `jq` and `curl` available


## Step 1: Deploy Keycloak

Deploy Keycloak as the central identity provider:

```bash
kubectl create namespace security-demo

# Deploy Keycloak
kubectl apply -n security-demo -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: keycloak
  labels:
    app: keycloak
spec:
  replicas: 1
  selector:
    matchLabels:
      app: keycloak
  template:
    metadata:
      labels:
        app: keycloak
    spec:
      containers:
        - name: keycloak
          image: quay.io/keycloak/keycloak:26.0
          args: ["start-dev"]
          env:
            - name: KC_BOOTSTRAP_ADMIN_USERNAME
              value: admin
            - name: KC_BOOTSTRAP_ADMIN_PASSWORD
              value: admin
          ports:
            - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: keycloak
spec:
  selector:
    app: keycloak
  ports:
    - port: 8080
      targetPort: 8080
EOF

kubectl wait --for=condition=Available deployment/keycloak -n security-demo --timeout=120s
```

Port-forward to access the Keycloak admin console:
```bash
kubectl port-forward svc/keycloak 8080:8080 -n security-demo &
```

**Demo point:** Open http://localhost:8080 and log in with admin/admin.


## Step 2: Configure the Keycloak Realm

Create a realm, clients, and users for the demo:

```bash
# Get admin token
ADMIN_TOKEN=$(curl -s -X POST "http://localhost:8080/realms/master/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin&password=admin&grant_type=password&client_id=admin-cli" | jq -r '.access_token')

# Create realm
curl -s -X POST "http://localhost:8080/admin/realms" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"realm": "kafka-security", "enabled": true}'

# Create client for Kafka brokers
curl -s -X POST "http://localhost:8080/admin/realms/kafka-security/clients" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "clientId": "kafka-broker",
    "enabled": true,
    "clientAuthenticatorType": "client-secret",
    "secret": "kafka-broker-secret",
    "serviceAccountsEnabled": true,
    "directAccessGrantsEnabled": true
  }'

# Create client for producers
curl -s -X POST "http://localhost:8080/admin/realms/kafka-security/clients" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "clientId": "kafka-producer",
    "enabled": true,
    "clientAuthenticatorType": "client-secret",
    "secret": "producer-secret",
    "directAccessGrantsEnabled": true
  }'

# Create client for consumers
curl -s -X POST "http://localhost:8080/admin/realms/kafka-security/clients" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "clientId": "kafka-consumer",
    "enabled": true,
    "clientAuthenticatorType": "client-secret",
    "secret": "consumer-secret",
    "directAccessGrantsEnabled": true
  }'

# Create client for Apicurio Registry
curl -s -X POST "http://localhost:8080/admin/realms/kafka-security/clients" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "clientId": "apicurio-registry",
    "enabled": true,
    "clientAuthenticatorType": "client-secret",
    "secret": "registry-secret",
    "serviceAccountsEnabled": true,
    "directAccessGrantsEnabled": true
  }'
```

**Demo point:** Show the realm configuration in the Keycloak admin console — one realm, four clients, each with its own role in the data platform.


## Step 3: Deploy Kafka with OAuth2 Authentication

Deploy a Strimzi Kafka cluster configured to use Keycloak for OAuth2 authentication:

```bash
kubectl apply -n security-demo -f - <<'EOF'
apiVersion: kafka.strimzi.io/v1beta2
kind: Kafka
metadata:
  name: secured-kafka
spec:
  kafka:
    version: 3.9.0
    replicas: 1
    listeners:
      - name: oauth
        port: 9093
        type: internal
        tls: true
        authentication:
          type: oauth
          validIssuerUri: http://keycloak:8080/realms/kafka-security
          jwksEndpointUri: http://keycloak:8080/realms/kafka-security/protocol/openid-connect/certs
          userNameClaim: preferred_username
          clientId: kafka-broker
          clientSecret:
            secretName: kafka-broker-oauth
            key: clientSecret
    authorization:
      type: simple
      superUsers:
        - User:service-account-kafka-broker
    config:
      offsets.topic.replication.factor: 1
      transaction.state.log.replication.factor: 1
      transaction.state.log.min.isr: 1
    storage:
      type: ephemeral
  zookeeper:
    replicas: 1
    storage:
      type: ephemeral
  entityOperator:
    topicOperator: {}
    userOperator: {}
---
apiVersion: v1
kind: Secret
metadata:
  name: kafka-broker-oauth
type: Opaque
stringData:
  clientSecret: kafka-broker-secret
EOF
```

**Demo point:** Show the Kafka listener configuration — OAuth2 authentication with Keycloak as the JWKS endpoint. Highlight `userNameClaim: preferred_username` which maps the OAuth2 token to a Kafka principal.


## Step 4: Deploy Apicurio Registry with Keycloak Authentication

```bash
kubectl apply -n security-demo -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apicurio-registry
spec:
  replicas: 1
  selector:
    matchLabels:
      app: apicurio-registry
  template:
    metadata:
      labels:
        app: apicurio-registry
    spec:
      containers:
        - name: registry
          image: quay.io/apicurio/apicurio-registry:3.0.6
          env:
            - name: APICURIO_AUTH_ENABLED
              value: "true"
            - name: QUARKUS_OIDC_AUTH_SERVER_URL
              value: http://keycloak:8080/realms/kafka-security
            - name: QUARKUS_OIDC_CLIENT_ID
              value: apicurio-registry
            - name: QUARKUS_OIDC_CLIENT_CREDENTIALS_SECRET
              value: registry-secret
          ports:
            - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: apicurio-registry
spec:
  selector:
    app: apicurio-registry
  ports:
    - port: 8080
      targetPort: 8080
EOF

kubectl wait --for=condition=Available deployment/apicurio-registry -n security-demo --timeout=120s
```

**Demo point:** Show that `APICURIO_AUTH_ENABLED=true` activates OIDC authentication. The registry shares the same Keycloak realm as Kafka — one identity model for the entire platform.


## Step 5: Create a Test Topic with ACLs

```bash
kubectl apply -n security-demo -f - <<'EOF'
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: secured-events
  labels:
    strimzi.io/cluster: secured-kafka
spec:
  partitions: 3
  replicas: 1
EOF
```


## Using the Demo

### Demonstrate Authentication (Happy Path)

Get an OAuth2 token for the producer and produce a message:

```bash
# Get producer token from Keycloak
PRODUCER_TOKEN=$(curl -s -X POST "http://localhost:8080/realms/kafka-security/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=kafka-producer&client_secret=producer-secret&grant_type=client_credentials" | jq -r '.access_token')

echo "Producer token acquired"

# Decode the JWT to show the claims
echo $PRODUCER_TOKEN | cut -d'.' -f2 | base64 -d 2>/dev/null | jq
```

**Demo point:** Decode the JWT and show the claims — `client_id`, `realm_access.roles`, `scope`. This is the identity that Kafka sees.

### Demonstrate Authorization Failure

Try producing without proper authorization:

```bash
# Get consumer token (should not have produce permissions)
CONSUMER_TOKEN=$(curl -s -X POST "http://localhost:8080/realms/kafka-security/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=kafka-consumer&client_secret=consumer-secret&grant_type=client_credentials" | jq -r '.access_token')

# Attempt to produce with consumer credentials — should fail
```

**Demo point:** Show the authorization error. The consumer client can read from topics but cannot write — fine-grained access control enforced by Kafka ACLs backed by Keycloak identities.

### Demonstrate Registry Authentication

```bash
kubectl port-forward svc/apicurio-registry 8081:8080 -n security-demo &

# Try accessing registry without token — should get 401
curl -s -o /dev/null -w "%{http_code}" http://localhost:8081/apis/registry/v3/groups

# Access with valid token — should succeed
curl -s -H "Authorization: Bearer $PRODUCER_TOKEN" \
  http://localhost:8081/apis/registry/v3/groups | jq
```

**Demo point:** The same OAuth2 token that authenticates to Kafka also authenticates to Apicurio Registry. No separate credentials — one identity model for the entire data platform.


## Key Talking Points

1. **Centralized identity** — Keycloak provides one OAuth2/OIDC identity for Kafka, Apicurio Registry, and applications. No more fragmented credentials per component.
2. **Fine-grained authorization** — Kafka ACLs map to OAuth2 client identities. Producers can write, consumers can read, and these permissions are managed centrally.
3. **Schema governance with authentication** — Apicurio Registry's OIDC integration means schema evolution is also access-controlled. Not everyone can modify production schemas.
4. **Zero-trust posture** — Every connection is authenticated (OAuth2 tokens) and encrypted (mTLS). No implicit trust between components.
5. **Common pitfalls to discuss:**
   - Token expiration handling in long-running Kafka consumers
   - JWKS endpoint caching and refresh intervals
   - The "works in dev, fails in prod" TLS certificate chain issues
   - Configuring Kafka client `sasl.jaas.config` for OAuth2 (non-obvious syntax)
