#!/bin/bash
# Produce invalid messages through the Kroxylicious proxy — all should be REJECTED
set -euo pipefail

PROXY_BOOTSTRAP="${PROXY_BOOTSTRAP:-localhost:19092}"

echo "=== Producing Invalid Messages (should be rejected by proxy) ==="
echo ""

echo "--- ORD-002: Missing required field 'currency' ---"
echo '{"orderId":"ORD-002","customerId":"CUST-42","amount":50.00}' | \
  docker exec -i kafka kafka-console-producer.sh \
    --bootstrap-server "$PROXY_BOOTSTRAP" \
    --topic orders 2>&1
echo ""

echo "--- ORD-003: Wrong type — amount is a string ---"
echo '{"orderId":"ORD-003","customerId":"CUST-42","amount":"free","currency":"USD"}' | \
  docker exec -i kafka kafka-console-producer.sh \
    --bootstrap-server "$PROXY_BOOTSTRAP" \
    --topic orders 2>&1
echo ""

echo "--- ORD-004: Invalid enum — BTC not in [USD, EUR, GBP] ---"
echo '{"orderId":"ORD-004","customerId":"CUST-42","amount":25.00,"currency":"BTC"}' | \
  docker exec -i kafka kafka-console-producer.sh \
    --bootstrap-server "$PROXY_BOOTSTRAP" \
    --topic orders 2>&1
echo ""

echo "All three messages should have been REJECTED by Kroxylicious"
echo "Check the proxy logs for validation error details"
