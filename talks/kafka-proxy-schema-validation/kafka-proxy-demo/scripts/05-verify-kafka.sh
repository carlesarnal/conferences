#!/bin/bash
# Verify that only valid messages reached Kafka
set -euo pipefail

echo "=== Verifying Kafka Contents ==="
echo ""
echo "Only valid messages should appear (ORD-001, ORD-005):"
echo "Invalid messages (ORD-002, ORD-003, ORD-004) were blocked by the proxy"
echo ""

docker exec kafka kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic orders \
  --from-beginning \
  --timeout-ms 5000

echo ""
echo "KEY POINT: Data quality enforced at the infrastructure layer"
echo "Producers don't need SDK changes — the proxy handles validation transparently"
