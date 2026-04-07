# Keycloak + Strimzi + Apicurio Registry Security Demo

Demonstrates unified, zero-trust security for a data platform using Keycloak (OAuth2/OIDC), Strimzi (Kafka on Kubernetes), and Apicurio Registry (CNCF sandbox).

## Quick Start (Kubernetes)

```bash
# Install Strimzi operator first
kubectl apply -f https://strimzi.io/install/latest?namespace=security-demo

# Deploy all components
kubectl apply -f k8s/01-namespace.yaml
kubectl apply -f k8s/02-keycloak.yaml
kubectl wait --for=condition=Available deployment/keycloak -n security-demo --timeout=120s

# Configure Keycloak realm and clients
kubectl port-forward svc/keycloak 8080:8080 -n security-demo &
./scripts/01-setup-keycloak.sh

# Deploy Kafka with OAuth2 and Registry with OIDC
kubectl apply -f k8s/03-kafka-oauth.yaml
kubectl apply -f k8s/04-apicurio-registry-oidc.yaml

# Run the auth demo
kubectl port-forward svc/apicurio-registry 8081:8080 -n security-demo &
./scripts/02-demo-auth.sh
```

## Components

| Manifest | Component | Purpose |
|---|---|---|
| `k8s/01-namespace.yaml` | Namespace | `security-demo` namespace |
| `k8s/02-keycloak.yaml` | Keycloak | Central identity provider (OAuth2/OIDC) |
| `k8s/03-kafka-oauth.yaml` | Strimzi Kafka | Kafka cluster with OAuth2 listener + ACL authorization |
| `k8s/04-apicurio-registry-oidc.yaml` | Apicurio Registry | Schema registry with OIDC authentication |

## Scripts

| Script | Purpose |
|---|---|
| `01-setup-keycloak.sh` | Create realm, clients (broker, producer, consumer, registry) |
| `02-demo-auth.sh` | Demonstrate token acquisition, JWT inspection, auth enforcement |

## Architecture

- **Keycloak** provides OAuth2/OIDC tokens for all components
- **Kafka** validates tokens via JWKS endpoint, maps to principals for ACL authorization
- **Apicurio Registry** uses the same OIDC realm for authentication
- One identity, one realm, one security model for the entire platform
