#!/usr/bin/env bash
#
# Copyright (C) 2022 David Härdeman <david@hardeman.nu>
#
# SPDX-License-Identifier: MIT
#
# This script automates the uninstallation of the Turris Omnia TLS project
# on a Turris Omnia router. Certificates will not be deleted from the
# file system.

set -o nounset -o pipefail -o errexit -o errtrace

log_message() {
    # Display a log message if the script is used interactively, otherwise
    # write the log message to syslog.
    local msg="${1:-}"

    if [ -n "${msg}" ]; then
        if [ -t 0 ]; then
            echo "${TOT_SCRIPT}: ${msg}" 1>&2
        else
            if type logger > /dev/null 2>&1; then
                logger -t "${TOT_SCRIPT}[${PID}]" "${msg}"
            fi
        fi
    fi
}

log_message "Removing cron job for certificate renewal"
rm -f "/etc/cron.d/turris-omnia-tls"

log_message "Removing custom lighttp webroot configuration"
rm -f "/etc/lighttpd/conf.d/39-acme-webroot.conf"

log_message "Removing custom lighttp TLS configuration"
rm -f "/etc/lighttpd/conf.d/40-acme-tls.conf"

log_message "Removing updater configuration"
rm -f "/etc/updater/conf.d/no-upstream-ssl.lua"

log_message "Reinstalling the lighttpd-https-cert package"
opkg install lighttpd-https-cert > /dev/null

log_message "Restarting lighttpd"
/etc/init.d/lighttpd restart
