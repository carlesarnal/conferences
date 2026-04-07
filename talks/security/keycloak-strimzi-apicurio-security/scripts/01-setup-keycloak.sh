#!/bin/bash
# Configure Keycloak realm with clients for Kafka, producers, consumers, and Apicurio
set -euo pipefail

KEYCLOAK_URL="${KEYCLOAK_URL:-http://localhost:8080}"

echo "=== Configuring Keycloak ==="

# Get admin token
ADMIN_TOKEN=$(curl -s -X POST "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin&password=admin&grant_type=password&client_id=admin-cli" | jq -r '.access_token')

if [ "$ADMIN_TOKEN" = "null" ] || [ -z "$ADMIN_TOKEN" ]; then
  echo "ERROR: Failed to get admin token. Is Keycloak running at $KEYCLOAK_URL?"
  exit 1
fi

echo "Admin token acquired"

# Create realm
echo "Creating realm: kafka-security"
curl -s -X POST "$KEYCLOAK_URL/admin/realms" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"realm": "kafka-security", "enabled": true}' || true

# Create clients
for client_config in \
  '{"clientId":"kafka-broker","secret":"kafka-broker-secret","serviceAccountsEnabled":true,"directAccessGrantsEnabled":true}' \
  '{"clientId":"kafka-producer","secret":"producer-secret","serviceAccountsEnabled":false,"directAccessGrantsEnabled":true}' \
  '{"clientId":"kafka-consumer","secret":"consumer-secret","serviceAccountsEnabled":false,"directAccessGrantsEnabled":true}' \
  '{"clientId":"apicurio-registry","secret":"registry-secret","serviceAccountsEnabled":true,"directAccessGrantsEnabled":true}'
do
  CLIENT_ID=$(echo "$client_config" | jq -r '.clientId')
  SECRET=$(echo "$client_config" | jq -r '.secret')
  SA=$(echo "$client_config" | jq -r '.serviceAccountsEnabled')
  DA=$(echo "$client_config" | jq -r '.directAccessGrantsEnabled')

  echo "Creating client: $CLIENT_ID"
  curl -s -X POST "$KEYCLOAK_URL/admin/realms/kafka-security/clients" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"clientId\": \"$CLIENT_ID\",
      \"enabled\": true,
      \"clientAuthenticatorType\": \"client-secret\",
      \"secret\": \"$SECRET\",
      \"serviceAccountsEnabled\": $SA,
      \"directAccessGrantsEnabled\": $DA
    }" || true
done

echo ""
echo "=== Keycloak configured ==="
echo "Realm: kafka-security"
echo "Clients: kafka-broker, kafka-producer, kafka-consumer, apicurio-registry"
echo "Admin console: $KEYCLOAK_URL/admin/master/console/#/kafka-security"
