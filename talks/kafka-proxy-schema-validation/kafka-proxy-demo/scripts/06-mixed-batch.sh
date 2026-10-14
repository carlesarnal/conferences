#!/bin/bash
# Send a valid and an invalid record in the same produce request, to observe batch behavior
set -euo pipefail
PROXY_BOOTSTRAP="${PROXY_BOOTSTRAP:-kroxylicious:9192}"

echo "=== Mixed batch: ORD-005 (valid) + ORD-006 (invalid) in one produce request ==="
printf '%s\n%s\n' \
  '{"orderId":"ORD-005","customerId":"CUST-7","amount":10.00,"currency":"GBP"}' \
  '{"orderId":"ORD-006","customerId":"CUST-7","amount":-5,"currency":"GBP"}' | \
  docker exec -i kafka /opt/kafka/bin/kafka-console-producer.sh \
    --bootstrap-server "$PROXY_BOOTSTRAP" --topic orders \
    --producer-property linger.ms=2000 \
    --producer-property batch.size=65536 \
    --producer-property acks=all --producer-property retries=0 \
    --producer-property delivery.timeout.ms=10000 \
    --producer-property request.timeout.ms=5000 2>&1 | grep -i "error\|exception" | head -4 || true
echo ""
echo "Check 05-verify-kafka.sh: does ORD-005 appear, or was the whole batch rejected?"
