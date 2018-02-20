#!/bin/sh

firewall_cfg="/etc/config/firewall"
firewall_cfg_backup="$firewall_cfg.bak"
certhome="/etc/lighttpd/certs"
ca_path="/etc/ssl/certs"

reload_firewall() {
    if ! /etc/init.d/firewall reload
    then
        echo 'Failed to reload firewall, aborting!'
        exit 1
    fi
}

modify_firewall() {
    # Backup firewall config
    cp "$firewall_cfg" "$firewall_cfg_backup"

    # Update firewall rules to allow access via port 80 from internet to acme.sh
    cat allow-port-80.gw >> "$firewall_cfg"
    reload_firewall
}

restore_firewall() {
    # Restore firewall to original state
    mv "$firewall_cfg_backup" "$firewall_cfg"
    reload_firewall
}
