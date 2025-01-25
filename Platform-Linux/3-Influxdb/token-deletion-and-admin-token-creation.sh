#!/usr/bin/env bash
#
# disable_old_tokens.sh
# ======================
# 1) Creates a new admin token
# 2) Deletes all other tokens
#
# Requires:
#   - 'influx' CLI
#   - Existing admin auth (via environment or a default config)
#

# --- CONFIGURE THESE VARIABLES ---
ORG_NAME="MyOrg"
HOST_URL="http://localhost:8086"

# Ensure you're already authenticated with a working admin token,
# e.g., via influx CLI config or environment variables.

echo "==> Creating a new all-access admin token..."
NEW_TOKEN_JSON=$(influx auth create \
  --org "${ORG_NAME}" \
  --all-access \
  --description "New Master Admin Token" \
  --json \
  --host "${HOST_URL}")
  
# Extract the new token ID and token string
NEW_TOKEN_ID=$(echo "${NEW_TOKEN_JSON}" | jq -r '.[0].id')
NEW_TOKEN_VALUE=$(echo "${NEW_TOKEN_JSON}" | jq -r '.[0].token')

echo "New admin token created!"
echo "Token ID: ${NEW_TOKEN_ID}"
echo "Token Value: ${NEW_TOKEN_VALUE}"
echo "==> Make sure to store this token securely."

echo "==> Listing all existing tokens..."
ALL_TOKENS=$(influx auth list \
  --org "${ORG_NAME}" \
  --host "${HOST_URL}" \
  --token "${NEW_TOKEN_VALUE}" \
  --json)

# If you want to keep some other tokens, you can filter them out here.
# This loop deletes every token except the NEW_TOKEN_ID we just created.
for TOKEN_ID in $(echo "${ALL_TOKENS}" | jq -r '.[].id'); do
  if [ "${TOKEN_ID}" != "${NEW_TOKEN_ID}" ]; then
    echo "Deleting token with ID: ${TOKEN_ID}"
    influx auth delete \
      --id "${TOKEN_ID}" \
      --host "${HOST_URL}" \
      --token "${NEW_TOKEN_VALUE}"
  fi
done

echo "==> All old tokens removed. Only the newly created admin token remains."
