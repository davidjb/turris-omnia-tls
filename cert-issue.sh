#!/bin/sh
certhome="/etc/lighttpd/certs"
ca_path="/etc/ssl/certs"
domain="$1"

mkdir -p "$certhome"
/srv/.acme.sh/acme.sh \
    --home "/srv/.acme.sh" \
    --issue \
    --standalone \
    --domain "$domain" \
    --keylength 4096 \
    --certhome "$certhome" \
    --ca-path "$ca_path" \
    --pre-hook "/srv/turris-omnia-tls/pre-hook.sh '$domain'" \
    --post-hook "/srv/turris-omnia-tls/post-hook.sh '$domain'" \
    --renew-hook "/srv/turris-omnia-tls/renew-hook.sh '$domain'" \
    --reloadcmd "/srv/turris-omnia-tls/reloadcmd.sh '$domain'"
