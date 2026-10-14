#!/bin/bash
# Shared helper: produce one JSON record through the proxy and report the outcome.
# Uses the Kafka console producer inside the kafka container, on the compose network.

PROXY_BOOTSTRAP="${PROXY_BOOTSTRAP:-kroxylicious:9192}"

produce_via_proxy() {
  local label="$1" payload="$2"
  echo "--- $label"
  echo "    $payload"
  local output
  output=$(echo "$payload" | docker exec -i kafka /opt/kafka/bin/kafka-console-producer.sh \
    --bootstrap-server "$PROXY_BOOTSTRAP" --topic orders \
    --producer-property acks=all \
    --producer-property retries=0 \
    --producer-property delivery.timeout.ms=10000 \
    --producer-property request.timeout.ms=5000 2>&1)
  if echo "$output" | grep -q -i "error\|exception"; then
    echo "    REJECTED:"
    echo "$output" | grep -i "error\|exception" | head -3 | sed 's/^/      /'
  else
    echo "    ACCEPTED"
  fi
  echo ""
}
