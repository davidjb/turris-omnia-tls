#!/bin/sh
# This script runs after issue or renew to reload the server.
# Variables available here are:
#   CA_CERT_PATH=[...]/ca.cer
#   CERT_FULLCHAIN_PATH=[...]/fullchain.cer
#   CERT_KEY_PATH=[...]/domain.example.com.key
#   CERT_PATH=[...]/domain.example.com.cer

if ! /etc/init.d/lighttpd restart
then
    echo 'Failed to reload lighttpd, aborting!'
    exit 1
fi
