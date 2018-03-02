#!/bin/sh
# This script runs after each successful renewal of a certificate

certhome="/etc/lighttpd/certs"
domain="$1"

# Join cert and key into pem for lighttpd
cat "$certhome/$domain/$domain.cer" "$certhome/$domain/$domain.key" > "$certhome/$domain/$domain.pem"

if ! /etc/init.d/lighttpd reload
then
    echo 'Failed to reload lighttpd, aborting!'
    exit 1
fi
