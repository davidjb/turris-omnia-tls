#!/bin/sh
certhome="/etc/lighttpd/certs"
ca_path="/etc/ssl/certs"
/root/.acme.sh/acme.sh \
    --cron \
    --certhome "$certhome" \
    --ca-path "$ca_path"
