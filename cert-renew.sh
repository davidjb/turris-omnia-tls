#!/bin/sh
certhome="/etc/lighttpd/certs"
ca_path="/etc/ssl/certs"
/srv/.acme.sh/acme.sh \
    --home "/srv/.acme.sh" \
    --cron \
    --certhome "$certhome" \
    --ca-path "$ca_path"
