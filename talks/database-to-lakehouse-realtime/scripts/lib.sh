#!/bin/bash
# Shared helpers for the lakehouse demo scripts
NS="${NS:-lakehouse-demo}"
STRIMZI_VERSION="${STRIMZI_VERSION:-1.2.0}"
K8S_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../k8s" && pwd)"

k() { kubectl -n "$NS" "$@"; }

trino() {
  k exec deploy/trino -- trino --output-format=ALIGNED --execute "$1"
}

psql_exec() {
  k exec deploy/postgres -- psql -U postgres -q -c "$1"
}

# Poll Trino until a query returns a line matching a pattern; prints elapsed seconds
wait_for_trino() {
  local query="$1" pattern="$2" timeout="${3:-240}" start
  start=$(date +%s)
  until k exec deploy/trino -- trino --execute "$query" 2>/dev/null | grep -q "$pattern"; do
    if [ $(( $(date +%s) - start )) -ge "$timeout" ]; then
      echo "Timed out after ${timeout}s waiting for: $query" >&2
      return 1
    fi
    sleep 2
  done
  echo $(( $(date +%s) - start ))
}
