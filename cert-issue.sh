#!/bin/sh
certhome="/etc/lighttpd/certs"
ca_path="/etc/ssl/certs"
domain="$1"

mkdir -p "$certhome"
/root/.acme.sh/acme.sh \
    --issue \
    --standalone \
    --domain "$domain" \
    --keylength 4096 \
    --certhome "$certhome" \
    --ca-path "$ca_path" \
    --pre-hook "/root/turris-omnia-tls/pre-hook.sh '$domain'" \
    --post-hook "/root/turris-omnia-tls/post-hook.sh '$domain'" \
    --renew-hook "/root/turris-omnia-tls/renew-hook.sh '$domain'"
