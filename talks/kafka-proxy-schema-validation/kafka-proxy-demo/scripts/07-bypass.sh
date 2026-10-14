#!/bin/bash
# Show the main limit: a producer that connects to the broker directly skips validation
set -euo pipefail

echo "=== Bypass: invalid ORD-007 sent straight to kafka:9092, not through the proxy ==="
echo '{"orderId":"ORD-007","amount":"not-a-number"}' | \
  docker exec -i kafka /opt/kafka/bin/kafka-console-producer.sh \
    --bootstrap-server kafka:9092 --topic orders 2>&1 | grep -i "error" || echo "    ACCEPTED by the broker"
echo ""
echo "Proxy validation only protects clients that go through the proxy."
echo "Enforce the path with network policy / broker authorization so clients cannot bypass it."
