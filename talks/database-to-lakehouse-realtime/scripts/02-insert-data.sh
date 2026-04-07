#!/bin/bash
# Insert sample data into PostgreSQL to trigger CDC events
set -euo pipefail

NAMESPACE="${NAMESPACE:-lakehouse-demo}"

echo "=== Inserting Data into PostgreSQL ==="
echo ""

echo "--- Inserting a new customer ---"
kubectl exec -it deploy/postgres -n "$NAMESPACE" -- psql --user postgres -c \
  "INSERT INTO inventory.customers VALUES (1005, 'Alice', 'Smith', 'alice@example.com');"
echo ""

echo "--- Inserting a new order ---"
kubectl exec -it deploy/postgres -n "$NAMESPACE" -- psql --user postgres -c \
  "INSERT INTO inventory.orders VALUES (10005, '2024-01-15', 1005, 3, 99.99);"
echo ""

echo "Data inserted. CDC events are flowing through Kafka to Iceberg."
echo "Wait a few seconds, then run 03-query-iceberg.sh to see results."
