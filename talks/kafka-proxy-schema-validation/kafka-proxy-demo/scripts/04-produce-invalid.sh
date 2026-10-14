#!/bin/bash
# Produce invalid orders through the proxy — expected to be rejected with INVALID_RECORD
set -euo pipefail
source "$(dirname "$0")/lib.sh"

echo "=== Invalid orders (expected: rejected) ==="
produce_via_proxy "ORD-002: missing required field 'currency'" \
  '{"orderId":"ORD-002","customerId":"CUST-42","amount":50.00}'
produce_via_proxy "ORD-003: wrong type, amount is a string" \
  '{"orderId":"ORD-003","customerId":"CUST-42","amount":"free","currency":"USD"}'
produce_via_proxy "ORD-004: currency BTC not in [USD, EUR, GBP]" \
  '{"orderId":"ORD-004","customerId":"CUST-42","amount":25.00,"currency":"BTC"}'
