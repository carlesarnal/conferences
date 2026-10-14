#!/bin/bash
# Start Kafka and Apicurio Registry, and wait until both are ready
set -euo pipefail
cd "$(dirname "$0")/.."

REGISTRY_URL="${REGISTRY_URL:-http://localhost:8080}"

echo "=== Starting Kafka and Apicurio Registry ==="
mkdir -p generated
docker compose up -d kafka apicurio-registry

echo -n "Waiting for Kafka"
until [ "$(docker inspect -f '{{.State.Health.Status}}' kafka 2>/dev/null)" = "healthy" ]; do
  echo -n "."; sleep 2
done
echo " ready"

echo -n "Waiting for Apicurio Registry"
until curl -sf "$REGISTRY_URL/apis/registry/v3/system/info" >/dev/null; do
  echo -n "."; sleep 2
done
echo " ready"
