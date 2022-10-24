#!/usr/bin/env bash
#
# Copyright (C) 2022 David Härdeman <david@hardeman.nu>
#
# SPDX-License-Identifier: MIT
#
# This script automates the installation of the Turris Omnia TLS project
# on a Turris Omnia router by asking a few questions (or obtaining them
# from environment variables).

set -o nounset -o pipefail -o errexit -o errtrace

cd "${0%/*}"

TOT_SCRIPT="$(basename "${0}")"
readonly TOT_SCRIPT
TOT_BASEDIR="$(pwd)"
readonly TOT_BASEDIR
readonly TOT_ACMEDIR="${TOT_BASEDIR}/acme.sh"
readonly TOT_ACMEHOME="${TOT_BASEDIR}/var/acme"

# Supported environment variables
TOT_EMAIL="${TOT_EMAIL:-}"
TOT_FQDN="${TOT_FQDN:-}"
TOT_HOSTNAME="${TOT_HOSTNAME:-}"

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

template_install() {
    # Install a template file to a given location, replacing variables
    # formatted as %VARIABLE% with the proper value
    local src="${1:-}"
    local dst="${2:-}"

    if [ -n "${dst}" ] && [ -n "${src}" ]; then
        sed \
            -e "s|%TOT_EMAIL%|${TOT_EMAIL}|g" \
            -e "s|%TOT_FQDN%|${TOT_FQDN}|g" \
            -e "s|%TOT_HOSTNAME%|${TOT_HOSTNAME}|g" \
            -e "s|%TOT_BASEDIR%|${TOT_BASEDIR}|g" \
            "${src}" > "${dst}"
    fi
}

add_crontab() {
    local crontab="${1:-}"
    local cmd="${TOT_BASEDIR}/cert-renew.sh"

    if [ -n "${crontab}" ]; then
        if ! grep -q "^[[:space:]]*[^#].*${cmd}" "${crontab}"; then
            echo "$(( RANDOM % 60 )) $(( RANDOM % 24 )) * * * ${cmd} > /dev/null" >> "${crontab}"
        fi
    fi
}

prompt_input() {
    # Ask the user for some input, unless a given variable is
    # already defined (e.g. via environment variables)
    local varname="${1:-}"
    local msg="${2:-}"
    local value=""

    if [ -n "${varname}" ] && [ -z "${!varname}" ] && [ -n "${msg}" ]; then
        if [ ! -t 0 ]; then
            log_message "non-interactive mode failed, missing options"
            exit 1
        fi

        read -r -p "${msg}: " value

        if [ -z "${value}" ]; then
            log_message "missing value for $varname"
            exit 1
        fi
        declare -g "${varname}"="${value}"
    fi
}

prompt_input "TOT_EMAIL" "Enter your email address"
prompt_input "TOT_FQDN" "Enter the FQDN of your router"
if [ -n "${TOT_FQDN}" ] && [ -z "${TOT_HOSTNAME}" ]; then
    TOT_HOSTNAME="$(echo "${TOT_FQDN}" | cut -d '.' -f1)"
fi

log_message "Installing the socat package"
opkg install socat > /dev/null

log_message "Installing the acme.sh script"
mkdir -p "${TOT_ACMEHOME}"
# Note that acme.sh fails to perform the installation if we don't chdir
cd "${TOT_ACMEDIR}"

./acme.sh \
    --home "${TOT_ACMEHOME}" \
    --install \
    --no-profile \
    --nocron \
    --email "${TOT_EMAIL}"

log_message "Setting the default CA"
./acme.sh \
    --home "${TOT_ACMEHOME}" \
    --set-default-ca \
    --server letsencrypt

cd "${TOT_BASEDIR}"

log_message "Removing the lighttpd-https-cert package"
opkg remove lighttpd-https-cert > /dev/null

log_message "Stop updater from automatically reinstalling lighttpd-https-cert"
cp updater_custom.lua /etc/updater/conf.d/no-upstream-ssl.lua

log_message "Installing the lighttpd-mod-openssl package"
opkg install lighttpd-mod-openssl > /dev/null

log_message "Installing custom lighttp webroot configuration"
template_install "lighttpd_webroot.conf" "/etc/lighttpd/conf.d/39-acme-webroot.conf"

log_message "Restarting lighttpd"
/etc/init.d/lighttpd restart
sleep 3

log_message "Issuing certificate"
./cert-issue.sh "${TOT_FQDN}"

log_message "Installing custom lighttp TLS configuration"
template_install "lighttpd_tls.conf" "/etc/lighttpd/conf.d/40-acme-tls.conf"

log_message "Restarting lighttpd again"
/etc/init.d/lighttpd restart
sleep 3

log_message "Adding a crontab entry for certificate renewal"
add_crontab "/etc/crontabs/root"
