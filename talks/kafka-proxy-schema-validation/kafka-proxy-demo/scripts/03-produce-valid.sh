#!/bin/bash
# Produce valid messages through the Kroxylicious proxy
set -euo pipefail

PROXY_BOOTSTRAP="${PROXY_BOOTSTRAP:-localhost:19092}"

echo "=== Producing Valid Messages (through proxy at $PROXY_BOOTSTRAP) ==="
echo ""

echo "--- Order ORD-001: Valid EUR order ---"
echo '{"orderId":"ORD-001","customerId":"CUST-42","amount":99.95,"currency":"EUR"}' | \
  docker exec -i kafka kafka-console-producer.sh \
    --bootstrap-server "$PROXY_BOOTSTRAP" \
    --topic orders
echo "Sent ORD-001"

echo "--- Order ORD-005: Valid USD order ---"
echo '{"orderId":"ORD-005","customerId":"CUST-99","amount":250.00,"currency":"USD"}' | \
  docker exec -i kafka kafka-console-producer.sh \
    --bootstrap-server "$PROXY_BOOTSTRAP" \
    --topic orders
echo "Sent ORD-005"

echo ""
echo "Both messages passed schema validation and reached Kafka"
