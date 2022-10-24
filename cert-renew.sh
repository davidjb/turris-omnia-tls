#!/bin/sh
certhome="/etc/lighttpd/certs"
tothome="/srv/turris-omnia-tls"
acmehome="${tothome}/var/acme"
ca_path="/etc/ssl/certs"

"${acmehome}/acme.sh" \
    --home "${tothome}" \
    --cron \
    --certhome "${certhome}" \
    --ca-path "${ca_path}"
