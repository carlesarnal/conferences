#!/bin/bash
# Remove the demo namespace (Kafka, Connect, storage, catalog, Trino, Strimzi operator deployment)
set -euo pipefail
source "$(dirname "$0")/lib.sh"
kubectl delete namespace "$NS" --wait=true
echo "Strimzi CRDs and cluster roles are cluster-scoped and were left in place."
