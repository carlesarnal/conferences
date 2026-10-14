#!/bin/bash
# Create the orders topic directly on Kafka
set -euo pipefail

echo "=== Creating orders topic ==="
docker exec kafka /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server kafka:9092 \
  --create --if-not-exists --topic orders --partitions 1 --replication-factor 1
