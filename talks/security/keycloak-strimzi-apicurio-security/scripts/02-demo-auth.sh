#!/bin/bash
# Demonstrate OAuth2 authentication and authorization flows
set -euo pipefail

KEYCLOAK_URL="${KEYCLOAK_URL:-http://localhost:8080}"
REGISTRY_URL="${REGISTRY_URL:-http://localhost:8081}"

echo "=== Security Demo ==="
echo ""

# Get producer token
echo "--- Acquiring producer token ---"
PRODUCER_TOKEN=$(curl -s -X POST "$KEYCLOAK_URL/realms/kafka-security/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=kafka-producer&client_secret=producer-secret&grant_type=client_credentials" | jq -r '.access_token')
echo "Producer token acquired"
echo ""

# Decode JWT
echo "--- JWT Claims (producer) ---"
echo "$PRODUCER_TOKEN" | cut -d'.' -f2 | base64 -d 2>/dev/null | jq '{iss, sub, azp, scope, exp}' 2>/dev/null || echo "(base64 decode may need padding adjustment)"
echo ""

# Get consumer token
echo "--- Acquiring consumer token ---"
CONSUMER_TOKEN=$(curl -s -X POST "$KEYCLOAK_URL/realms/kafka-security/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=kafka-consumer&client_secret=consumer-secret&grant_type=client_credentials" | jq -r '.access_token')
echo "Consumer token acquired"
echo ""

# Registry access without token (should fail)
echo "--- Registry access WITHOUT token ---"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$REGISTRY_URL/apis/registry/v3/groups")
echo "Response: HTTP $HTTP_CODE (expected: 401 Unauthorized)"
echo ""

# Registry access with token (should succeed)
echo "--- Registry access WITH producer token ---"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $PRODUCER_TOKEN" "$REGISTRY_URL/apis/registry/v3/groups")
echo "Response: HTTP $HTTP_CODE (expected: 200 OK)"
echo ""

# Show that the same token works for both Kafka and Registry
echo "--- Key takeaway ---"
echo "The SAME OAuth2 token authenticates to both Kafka and Apicurio Registry."
echo "One identity model for the entire data platform."
echo ""
echo "=== Demo complete ==="
