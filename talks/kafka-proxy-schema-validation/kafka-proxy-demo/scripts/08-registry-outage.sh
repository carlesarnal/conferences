#!/bin/bash
# Observe filter behavior while Apicurio Registry is unavailable
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/lib.sh

echo "=== Registry outage: stopping Apicurio Registry ==="
docker stop apicurio-registry >/dev/null
echo ""

produce_via_proxy "ORD-008: VALID order while the registry is down" \
  '{"orderId":"ORD-008","customerId":"CUST-1","amount":1,"currency":"USD"}'

echo "Observed with Kroxylicious 0.24.0: the valid record is rejected (fail-closed)."
echo "The producer receives InvalidRecordException with context=SCHEMA_RESOLUTION_ERROR,"
echo "the same exception type used for genuinely invalid data."
echo ""

echo "=== Restarting Apicurio Registry ==="
docker start apicurio-registry >/dev/null
echo -n "Waiting for Apicurio Registry"
until curl -sf "${REGISTRY_URL:-http://localhost:8080}/apis/registry/v3/system/info" >/dev/null; do
  echo -n "."; sleep 2
done
echo " ready"
