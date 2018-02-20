#!/bin/sh
# Version 1.0.0
source ./cert-common.sh
modify_firewall
./acme.sh \
    --cron \
    --certhome "$certhome" \
    --ca-path "$ca_path"
restore_firewall
