#!/usr/bin/env bash
#
# Copyright (C) 2018-2022 David Beitey <david@davidjb.com>
# Copyright (C) 2022 David Härdeman <david@hardeman.nu>
#
# SPDX-License-Identifier: MIT
#
# This script renews already issued certs and is meant to be executed
# periodically via e.g. cron.

set -o nounset -o pipefail -o errexit -o errtrace

cd "${0%/*}"
tothome="$(pwd)"
certhome="/etc/lighttpd/certs"
acmehome="${tothome}/var/acme"
ca_path="/etc/ssl/certs"

"${acmehome}/acme.sh" \
    --home "${tothome}" \
    --cron \
    --certhome "${certhome}" \
    --ca-path "${ca_path}"
