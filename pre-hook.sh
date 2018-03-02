#!/bin/sh

firewall_cfg="/etc/config/firewall"
firewall_cfg_backup="$firewall_cfg.bak"

# Backup firewall config
cp "$firewall_cfg" "$firewall_cfg_backup"

# Update firewall rules to allow access via port 80 from internet to acme.sh
cat /root/turris-omnia-tls/allow-port-80.gw >> "$firewall_cfg"

if ! /etc/init.d/firewall reload
then
    echo 'Failed to reload firewall, aborting!'
    exit 1
fi
