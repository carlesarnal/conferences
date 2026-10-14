#!/bin/bash
# Insert a row in PostgreSQL and measure how long it takes to become queryable in Iceberg
set -euo pipefail
source "$(dirname "$0")/lib.sh"

echo "=== Insert customer 1005 in PostgreSQL ==="
psql_exec "INSERT INTO inventory.customers VALUES (1005, 'Alice', 'Smith', 'alice@example.com');"

echo "Waiting for the row in Iceberg (commit interval: 10s)..."
s=$(wait_for_trino "SELECT count(*) FROM iceberg.inventory.customers WHERE id = 1005" '"1"')
echo "Row 1005 queryable in Iceberg after ${s}s (measured, including Trino CLI time)"
echo ""
trino "SELECT id, first_name, last_name, email, _cdc.op AS op FROM iceberg.inventory.customers ORDER BY id"
