#!/bin/sh
# This script runs after each call to acme.sh; for either success or failure

# Variables available here on success are:
#   CA_CERT_PATH=[...]/ca.cer
#   CERT_FULLCHAIN_PATH=[...]/fullchain.cer
#   CERT_KEY_PATH=[...]/domain.example.com.key
#   CERT_PATH=[...]/domain.example.com.cer
#   Le_Domain=domain.example.com
# These are not set on failure.

# Remove firewall rules we set up earlier; use the comment to ensure only our rules are removed
handle=$(nft --handle list chain inet fw4 input_wan | grep 'turris-omnia-tls acme.sh' | sed -nE 's/^.* # handle (.+)$/\1/p')
nft delete rule inet fw4 input_wan handle "$handle"

# Generate a .pem file containing both cert and key
if [ -n "$CERT_PATH" ]; then
  cat "$CERT_PATH" "$CERT_KEY_PATH" > "$Le_Domain.pem"
fi
