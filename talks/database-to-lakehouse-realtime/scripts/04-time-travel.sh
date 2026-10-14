#!/bin/bash
# Snapshots, time travel, and the latest state per key from the append-only changelog
set -euo pipefail
source "$(dirname "$0")/lib.sh"

echo "=== Snapshots: one per sink commit, not one per change event ==="
trino 'SELECT snapshot_id, committed_at, operation, summary['"'"'added-records'"'"'] AS added_records FROM iceberg.inventory."customers$snapshots" ORDER BY committed_at'

first=$(k exec deploy/trino -- trino --execute \
  'SELECT snapshot_id FROM iceberg.inventory."customers$snapshots" ORDER BY committed_at LIMIT 1' | tr -d '"')

echo ""
echo "=== Time travel: the table as of the first snapshot ==="
trino "SELECT id, first_name FROM iceberg.inventory.customers FOR VERSION AS OF $first ORDER BY id"

echo ""
echo "=== Current state: latest row per customer, excluding deletes ==="
trino "SELECT id, first_name, last_name, phone
       FROM (SELECT *, row_number() OVER (PARTITION BY id ORDER BY _cdc.offset DESC) AS rn
             FROM iceberg.inventory.customers)
       WHERE rn = 1 AND _cdc.op <> 'D'
       ORDER BY id"
