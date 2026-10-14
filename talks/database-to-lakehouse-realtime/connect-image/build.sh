#!/bin/bash
# Build the Kafka Connect image: Strimzi Kafka 4.3.1 + Debezium PostgreSQL + Apicurio converter + Apache Iceberg sink.
# The Apache Iceberg Kafka Connect runtime is not published as a binary, so it is built from the source release.
set -euo pipefail
cd "$(dirname "$0")"

ICEBERG_VERSION="${ICEBERG_VERSION:-1.11.0}"
DEBEZIUM_VERSION="${DEBEZIUM_VERSION:-3.6.3.Final}"
APICURIO_VERSION="${APICURIO_VERSION:-3.3.3}"
IMAGE="${IMAGE:-localhost/lakehouse-connect:1.0}"
WORK="${WORK:-$(pwd)/.build}"

mkdir -p "$WORK" plugins
cd "$WORK"

if [ ! -f "iceberg-kafka-connect-runtime-$ICEBERG_VERSION.zip" ]; then
  echo "=== Building Apache Iceberg $ICEBERG_VERSION Kafka Connect runtime (needs JDK 17 or 21) ==="
  SRC="apache-iceberg-$ICEBERG_VERSION"
  curl -sfLO "https://dlcdn.apache.org/iceberg/$SRC/$SRC.tar.gz"
  curl -sfLO "https://downloads.apache.org/iceberg/$SRC/$SRC.tar.gz.sha512"
  shasum -a 512 -c "$SRC.tar.gz.sha512"
  tar xzf "$SRC.tar.gz"
  (cd "$SRC" && ./gradlew -q -x test -x integrationTest :iceberg-kafka-connect:iceberg-kafka-connect-runtime:distZip)
  cp "$SRC/kafka-connect/kafka-connect-runtime/build/distributions/iceberg-kafka-connect-runtime-$ICEBERG_VERSION.zip" .
fi

echo "=== Downloading Debezium $DEBEZIUM_VERSION and Apicurio converter $APICURIO_VERSION ==="
curl -sfL -o debezium.tgz "https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/$DEBEZIUM_VERSION/debezium-connector-postgres-$DEBEZIUM_VERSION-plugin.tar.gz"
curl -sfL -o apicurio.tgz "https://repo1.maven.org/maven2/io/apicurio/apicurio-registry-distro-connect-converter/$APICURIO_VERSION/apicurio-registry-distro-connect-converter-$APICURIO_VERSION.tar.gz"

cd ..
rm -rf plugins && mkdir -p plugins/debezium-postgres plugins/apicurio-converter
tar xzf "$WORK/debezium.tgz" -C plugins/debezium-postgres
tar xzf "$WORK/apicurio.tgz" -C plugins/apicurio-converter
unzip -q "$WORK/iceberg-kafka-connect-runtime-$ICEBERG_VERSION.zip" -d plugins/

echo "=== Building $IMAGE ==="
docker build -t "$IMAGE" .

if command -v minikube >/dev/null && minikube status >/dev/null 2>&1; then
  echo "=== Loading $IMAGE into minikube ==="
  minikube image load "$IMAGE"
fi
