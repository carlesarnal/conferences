#!/bin/bash
# Read the orders topic directly from Kafka (bypassing the proxy)
set -euo pipefail

echo "=== Records stored in Kafka (read directly from the broker) ==="
docker exec kafka /opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server kafka:9092 --topic orders \
  --from-beginning --timeout-ms 5000 2>/dev/null || true
echo ""
echo "Only records accepted by the proxy should appear above."
