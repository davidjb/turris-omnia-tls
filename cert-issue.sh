#!/usr/bin/env bash
#
# Copyright (C) 2018-2022 David Beitey <david@davidjb.com>
# Copyright (C) 2022 David Härdeman <david@hardeman.nu>
#
# SPDX-License-Identifier: MIT
#
# This script is used once for the initial issuance of a certificate.

set -o nounset -o pipefail -o errexit -o errtrace

cd "${0%/*}"
tothome="$(pwd)"
certhome="/etc/lighttpd/certs"
acmehome="${tothome}/var/acme"
ca_path="/etc/ssl/certs"
webroot="${tothome}/var/webroot"
domain="$1"

mkdir -p "$certhome"
mkdir -p "$webroot"

"${acmehome}/acme.sh" \
    --home "${acmehome}" \
    --issue \
    --webroot "${webroot}" \
    --domain "${domain}" \
    --keylength 4096 \
    --certhome "${certhome}" \
    --ca-path "${ca_path}" \
    --pre-hook "${tothome}/pre-hook.sh '$domain'" \
    --post-hook "${tothome}/post-hook.sh '$domain'" \
    --renew-hook "${tothome}/renew-hook.sh '$domain'" \
    --reloadcmd "${tothome}/reloadcmd.sh '$domain'"
