#!/bin/sh
# This script runs after each call to acme.sh; for either success or failure

firewall_cfg="/etc/config/firewall"
firewall_cfg_backup="$firewall_cfg.bak"

# Restore original firewall config
mv "$firewall_cfg_backup" "$firewall_cfg"
if ! /etc/init.d/firewall reload
then
    echo 'Failed to reload firewall, aborting!'
    exit 1
fi
