#!/bin/bash
# Deploy Strimzi and every lakehouse component into the lakehouse-demo namespace.
# Prerequisite: connect-image/build.sh has built and loaded localhost/lakehouse-connect:1.0.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

echo "=== Namespace and Strimzi $STRIMZI_VERSION ==="
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -
curl -sfL "https://github.com/strimzi/strimzi-kafka-operator/releases/download/$STRIMZI_VERSION/strimzi-cluster-operator-$STRIMZI_VERSION.yaml" \
  | sed "s/namespace: .*/namespace: $NS/" | k apply -f - >/dev/null
k rollout status deploy/strimzi-cluster-operator --timeout=300s

echo "=== Kafka, PostgreSQL, Apicurio Registry, storage, catalog, Trino ==="
for f in 01-kafka.yaml 02-postgres-registry.yaml 03-storage-catalog.yaml 04-trino.yaml; do
  k apply -f "$K8S_DIR/$f"
done
k wait kafka/lakehouse --for=condition=Ready --timeout=600s
for d in postgres apicurio-registry seaweedfs iceberg-rest trino; do
  k rollout status "deploy/$d" --timeout=600s
done
k wait job/create-warehouse-bucket --for=condition=complete --timeout=300s

echo "=== Kafka Connect ==="
k apply -f "$K8S_DIR/05-connect.yaml"
k wait kafkaconnect/lakehouse-connect --for=condition=Ready --timeout=600s

echo "=== Connectors ==="
k apply -f "$K8S_DIR/06-connectors.yaml"
k wait kafkaconnector/postgres-source kafkaconnector/iceberg-sink --for=condition=Ready --timeout=300s

echo ""
echo "Waiting for the initial snapshot of inventory.customers to reach Iceberg..."
s=$(wait_for_trino "SELECT count(*) FROM iceberg.inventory.customers" '"4"' 300)
echo "Snapshot rows queryable in Iceberg after ${s}s"
