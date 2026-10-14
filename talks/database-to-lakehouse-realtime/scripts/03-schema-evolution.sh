#!/bin/bash
# Add a column in PostgreSQL and follow it through the registry and into the Iceberg table
set -euo pipefail
source "$(dirname "$0")/lib.sh"

versions() {
  k exec deploy/apicurio-registry -- curl -s \
    localhost:8080/apis/registry/v3/groups/default/artifacts/server1.inventory.customers-value/versions \
    | python3 -c "import sys,json;print([v['version'] for v in json.load(sys.stdin)['versions']])"
}

echo "=== Before: registry versions of the value schema ==="
versions

echo ""
echo "=== ALTER TABLE ... ADD COLUMN phone, then update customer 1005 ==="
psql_exec "ALTER TABLE inventory.customers ADD COLUMN phone VARCHAR(20);"
psql_exec "UPDATE inventory.customers SET phone = '+34-555-0001' WHERE id = 1005;"

s=$(wait_for_trino "SELECT phone FROM iceberg.inventory.customers WHERE id = 1005 AND phone IS NOT NULL" "555")
echo "New column populated in Iceberg after ${s}s"

echo ""
echo "=== After: registry versions (Debezium registered a new schema version) ==="
versions

echo ""
echo "=== Iceberg table: the column was added by the sink, no manual DDL ==="
trino "SELECT id, first_name, phone, _cdc.op AS op FROM iceberg.inventory.customers ORDER BY id, _cdc.offset"
echo ""
echo "Note: the sink appends a changelog. Customer 1005 has an insert (I) and an update (U) row."
