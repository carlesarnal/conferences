#!/bin/bash
# Deploy MinIO, Iceberg sink connector, and Trino on top of existing CDC infrastructure
set -euo pipefail

NAMESPACE="${NAMESPACE:-lakehouse-demo}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
K8S_DIR="$SCRIPT_DIR/../k8s"

echo "=== Deploying Lakehouse Components ==="
echo "Namespace: $NAMESPACE"
echo ""

# Create namespace if needed
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

echo "--- Deploying MinIO (S3-compatible storage) ---"
kubectl apply -f "$K8S_DIR/01-minio.yaml"
kubectl wait --for=condition=available deployment/minio -n "$NAMESPACE" --timeout=120s
echo "MinIO deployed"
echo ""

echo "--- Deploying Trino (query engine) ---"
kubectl apply -f "$K8S_DIR/03-trino.yaml"
kubectl wait --for=condition=available deployment/trino -n "$NAMESPACE" --timeout=120s
echo "Trino deployed"
echo ""

echo "--- Creating warehouse bucket in MinIO ---"
kubectl exec deploy/minio -n "$NAMESPACE" -- \
  mc alias set local http://localhost:9000 admin password 2>/dev/null || true
kubectl exec deploy/minio -n "$NAMESPACE" -- \
  mc mb local/warehouse --ignore-existing 2>/dev/null || true
echo "Warehouse bucket created"
echo ""

echo "--- Deploying Iceberg sink connector ---"
kubectl apply -f "$K8S_DIR/02-iceberg-sink-connector.yaml"
echo "Iceberg sink connector deployed"
echo ""

echo "=== Lakehouse components deployed ==="
echo "  MinIO:  port-forward with: kubectl port-forward svc/minio 9001:9001 -n $NAMESPACE"
echo "  Trino:  port-forward with: kubectl port-forward svc/trino 8080:8080 -n $NAMESPACE"
