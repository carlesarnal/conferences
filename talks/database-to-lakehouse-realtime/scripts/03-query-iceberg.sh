#!/bin/bash
# Query Iceberg tables via Trino to show real-time data availability
set -euo pipefail

NAMESPACE="${NAMESPACE:-lakehouse-demo}"

echo "=== Querying Iceberg Tables via Trino ==="
echo ""

echo "--- Customers table ---"
kubectl exec -it deploy/trino -n "$NAMESPACE" -- trino --execute \
  "SELECT * FROM iceberg.inventory.customers ORDER BY id;"
echo ""

echo "--- Orders table ---"
kubectl exec -it deploy/trino -n "$NAMESPACE" -- trino --execute \
  "SELECT * FROM iceberg.inventory.orders ORDER BY order_number;"
echo ""

echo "--- Iceberg snapshots (for time travel) ---"
kubectl exec -it deploy/trino -n "$NAMESPACE" -- trino --execute \
  "SELECT snapshot_id, committed_at, operation FROM iceberg.inventory.\"customers\$snapshots\" ORDER BY committed_at;"
