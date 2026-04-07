#!/bin/bash
# Run the complete kafka-proxy-schema-validation demo
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "========================================================="
echo "  Transparent Schema Validation at the Kafka Proxy Layer"
echo "========================================================="
echo ""
echo "Prerequisites:"
echo "  - docker compose up -d (from parent directory)"
echo "  - Kroxylicious proxy built and running (see README)"
echo "  - curl and jq installed"
echo ""

read -p "Press Enter to start..." _

echo ""
echo "STEP 1: Register the order schema"
echo "==================================="
"$SCRIPT_DIR/01-register-schema.sh"
echo ""
read -p "Press Enter to continue..." _

echo ""
echo "STEP 2: Create the Kafka topic"
echo "================================"
"$SCRIPT_DIR/02-create-topic.sh"
echo ""
read -p "Press Enter to continue..." _

echo ""
echo "STEP 3: Produce valid messages (through proxy)"
echo "================================================="
"$SCRIPT_DIR/03-produce-valid.sh"
echo ""
read -p "Press Enter to continue..." _

echo ""
echo "STEP 4: Produce invalid messages (rejected by proxy)"
echo "======================================================"
"$SCRIPT_DIR/04-produce-invalid.sh"
echo ""
read -p "Press Enter to continue..." _

echo ""
echo "STEP 5: Verify only valid messages in Kafka"
echo "=============================================="
"$SCRIPT_DIR/05-verify-kafka.sh"
echo ""

echo "========================================================="
echo "  Demo complete!"
echo ""
echo "  Key takeaways:"
echo "  1. Transparent — producers don't know the proxy exists"
echo "  2. Invalid messages never reach the broker"
echo "  3. Same registry, enforced at infrastructure layer"
echo "========================================================="
