#!/bin/sh
# This script runs after each successful renewal of a certificate

if ! /etc/init.d/lighttpd reload
then
    echo 'Failed to reload lighttpd, aborting!'
    exit 1
fi
