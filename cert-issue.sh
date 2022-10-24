#!/bin/sh
certhome="/etc/lighttpd/certs"
tothome="/srv/turris-omnia-tls"
acmehome="${tothome}/var/acme"
ca_path="/etc/ssl/certs"
webroot="${tothome}/var/webroot"
domain="$1"

mkdir -p "$certhome"
mkdir -p "$webroot"

"${acmehome}/acme.sh" \
    --home "${acmehome}" \
    --issue \
    --webroot "${webroot}" \
    --domain "${domain}" \
    --keylength 4096 \
    --certhome "${certhome}" \
    --ca-path "${ca_path}" \
    --pre-hook "${tothome}/pre-hook.sh '$domain'" \
    --post-hook "${tothome}/post-hook.sh '$domain'" \
    --renew-hook "${tothome}/renew-hook.sh '$domain'" \
    --reloadcmd "${tothome}/reloadcmd.sh '$domain'"
