#!/bin/sh
certhome="/etc/lighttpd/certs"
ca_path="/etc/ssl/certs"
webroot="/src/turris-omnia-tls/var/webroot"
domain="$1"

mkdir -p "$certhome"
mkdir -p "$webroot"

/srv/.acme.sh/acme.sh \
    --home "/srv/.acme.sh" \
    --issue \
    --webroot "$webroot" \
    --domain "$domain" \
    --keylength 4096 \
    --certhome "$certhome" \
    --ca-path "$ca_path" \
    --pre-hook "/srv/turris-omnia-tls/pre-hook.sh '$domain'" \
    --post-hook "/srv/turris-omnia-tls/post-hook.sh '$domain'" \
    --renew-hook "/srv/turris-omnia-tls/renew-hook.sh '$domain'" \
    --reloadcmd "/srv/turris-omnia-tls/reloadcmd.sh '$domain'"
