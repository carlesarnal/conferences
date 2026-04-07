#!/bin/bash
# Run the complete database-to-lakehouse demo end-to-end
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "================================================"
echo "  From Database to Lakehouse in Real-Time Demo"
echo "================================================"
echo ""
echo "Prerequisites:"
echo "  - Kubernetes cluster with Strimzi operator"
echo "  - CDC infrastructure deployed (see debezium-ocp-etc-demo)"
echo "  - kubectl configured"
echo ""

read -p "Press Enter to start..." _

echo ""
echo "STEP 1: Deploy lakehouse components (MinIO, Trino, Iceberg sink)"
echo "================================================================="
"$SCRIPT_DIR/01-deploy-lakehouse.sh"
echo ""
read -p "Press Enter to continue..." _

echo ""
echo "STEP 2: Insert data into PostgreSQL"
echo "====================================="
"$SCRIPT_DIR/02-insert-data.sh"
echo ""
read -p "Press Enter to continue (wait ~5s for CDC propagation)..." _

echo ""
echo "STEP 3: Query Iceberg tables via Trino"
echo "========================================"
"$SCRIPT_DIR/03-query-iceberg.sh"
echo ""
read -p "Press Enter to continue..." _

echo ""
echo "STEP 4: Schema evolution demo"
echo "==============================="
"$SCRIPT_DIR/04-schema-evolution.sh"
echo ""

echo "================================================"
echo "  Demo complete!"
echo ""
echo "  Key takeaways:"
echo "  1. Sub-second latency from DB commit to Iceberg"
echo "  2. Schema evolution flows automatically end-to-end"
echo "  3. Time travel queries via Iceberg snapshots"
echo "  4. 100% open source stack, no vendor lock-in"
echo "================================================"
