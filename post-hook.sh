#!/bin/sh
# This script runs after each call to acme.sh; for either success or failure

firewall_cfg="/etc/config/firewall"
firewall_cfg_backup="$firewall_cfg.bak"
certhome="/etc/lighttpd/certs"
domain="$1"

# Join cert and key into pem format for lighttpd
cat "$certhome/$domain/$domain.cer" "$certhome/$domain/$domain.key" > "$certhome/$domain/$domain.pem"

# Restore original firewall config
mv "$firewall_cfg_backup" "$firewall_cfg"
if ! /etc/init.d/firewall reload
then
    echo 'Failed to reload firewall, aborting!'
    exit 1
fi
