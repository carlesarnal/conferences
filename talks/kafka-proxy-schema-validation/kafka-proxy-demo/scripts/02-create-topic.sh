#!/bin/bash
# Create the orders topic in Kafka
set -euo pipefail

echo "=== Creating Kafka Topic ==="
echo ""

docker exec kafka kafka-topics.sh \
  --create --topic orders \
  --bootstrap-server localhost:9092 \
  --partitions 3 --replication-factor 1

echo "Topic 'orders' created"
