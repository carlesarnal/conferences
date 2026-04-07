#!/bin/bash
# Demonstrate automatic schema evolution from PostgreSQL through to Iceberg
set -euo pipefail

NAMESPACE="${NAMESPACE:-lakehouse-demo}"

echo "=== Schema Evolution Demo ==="
echo ""

echo "--- Step 1: Show current schema ---"
kubectl exec -it deploy/trino -n "$NAMESPACE" -- trino --execute \
  "DESCRIBE iceberg.inventory.customers;"
echo ""

echo "--- Step 2: Add a column in PostgreSQL ---"
kubectl exec -it deploy/postgres -n "$NAMESPACE" -- psql --user postgres -c \
  "ALTER TABLE inventory.customers ADD COLUMN phone VARCHAR(20);"
echo "Column 'phone' added to PostgreSQL"
echo ""

echo "--- Step 3: Insert data with the new column ---"
kubectl exec -it deploy/postgres -n "$NAMESPACE" -- psql --user postgres -c \
  "UPDATE inventory.customers SET phone = '+34-555-0001' WHERE id = 1005;"
echo ""

echo "Waiting 5 seconds for schema propagation..."
sleep 5

echo "--- Step 4: Show evolved schema in Iceberg ---"
kubectl exec -it deploy/trino -n "$NAMESPACE" -- trino --execute \
  "DESCRIBE iceberg.inventory.customers;"
echo ""

echo "--- Step 5: Query the new column ---"
kubectl exec -it deploy/trino -n "$NAMESPACE" -- trino --execute \
  "SELECT id, first_name, last_name, phone FROM iceberg.inventory.customers WHERE id = 1005;"
echo ""

echo "=== Schema evolution complete ==="
echo ""
echo "What just happened automatically:"
echo "  1. PostgreSQL schema changed (ALTER TABLE)"
echo "  2. Debezium detected the change, published events with new field"
echo "  3. Apicurio Registry registered a new schema version (BACKWARD compatible)"
echo "  4. Iceberg sink connector evolved the table DDL — no manual ALTER needed"
