#!/bin/sh
# This script runs after each call to acme.sh; for either success or failure

# Remove firewall rules we set up earlier; use the comment to ensure only our rules are removed
handle=$(nft --handle list chain inet fw4 input_wan | grep 'turris-omnia-tls acme.sh' | sed -nE 's/^.* # handle (.+)$/\1/p')
nft delete rule inet fw4 input_wan handle "$handle"
