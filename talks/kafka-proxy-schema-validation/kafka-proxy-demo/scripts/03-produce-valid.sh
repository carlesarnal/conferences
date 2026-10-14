#!/bin/bash
# Produce a valid order through the proxy — expected to be accepted
set -euo pipefail
source "$(dirname "$0")/lib.sh"

echo "=== Valid order (expected: accepted) ==="
produce_via_proxy "ORD-001: valid order" \
  '{"orderId":"ORD-001","customerId":"CUST-42","amount":99.95,"currency":"EUR"}'
