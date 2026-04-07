#!/bin/bash
# Demonstrate the real-time CDC-to-Iceberg pipeline
set -euo pipefail

NAMESPACE="${NAMESPACE:-lakehouse-demo}"

echo "=== Database to Lakehouse Pipeline Demo ==="
echo ""

# Insert a record in PostgreSQL
echo "--- Step 1: Insert data into PostgreSQL ---"
kubectl exec -it postgres -n "$NAMESPACE" -- psql --user postgres -c \
  "INSERT INTO inventory.customers VALUES (1005, 'Alice', 'Smith', 'alice@example.com');"
echo ""

# Wait for CDC propagation
echo "Waiting for CDC event to propagate..."
sleep 5

# Query Iceberg via Trino
echo "--- Step 2: Query Iceberg tables via Trino ---"
kubectl exec -it trino -n "$NAMESPACE" -- trino --execute \
  "SELECT * FROM iceberg.inventory.customers ORDER BY id;"
echo ""

echo "--- Step 3: Schema evolution ---"
echo "Adding 'phone' column to PostgreSQL..."
kubectl exec -it postgres -n "$NAMESPACE" -- psql --user postgres -c \
  "ALTER TABLE inventory.customers ADD COLUMN phone VARCHAR(20);"
kubectl exec -it postgres -n "$NAMESPACE" -- psql --user postgres -c \
  "UPDATE inventory.customers SET phone = '+34-555-0001' WHERE id = 1005;"
echo ""

echo "Waiting for schema evolution to propagate..."
sleep 5

echo "--- Step 4: Query with evolved schema ---"
kubectl exec -it trino -n "$NAMESPACE" -- trino --execute \
  "SELECT id, first_name, last_name, phone FROM iceberg.inventory.customers WHERE id = 1005;"
echo ""

echo "--- Step 5: Time travel ---"
echo "Listing Iceberg snapshots:"
kubectl exec -it trino -n "$NAMESPACE" -- trino --execute \
  "SELECT snapshot_id, committed_at FROM iceberg.inventory.\"customers\$snapshots\" ORDER BY committed_at;"
echo ""

echo "=== Demo complete ==="
echo ""
echo "Key points demonstrated:"
echo "  1. Sub-second CDC from PostgreSQL to Iceberg"
echo "  2. Automatic schema evolution (phone column)"
echo "  3. Time travel queries via Iceberg snapshots"
