#!/bin/sh
# Version 1.0.0
source ./cert-common.sh
domain="$1"

mkdir -p "$certhome"

# Trigger request to Let's Encrypt
# To issue manual requests for certificates, run the following command
# but without the `post-hook` or `reloadcmd` arguments.
modify_firewall
./acme.sh \
    --issue \
    --standalone \
    --domain "$domain" \
    --keylength 4096 \
    --certhome "$certhome" \
    --ca-path "$ca_path" \
    --post-hook "cat $certhome/$domain/$domain.cer $certhome/$domain/$domain.key > $certhome/$domain/$domain.pem" \
    --reloadcmd "/etc/init.d/lighttpd reload"
restore_firewall
