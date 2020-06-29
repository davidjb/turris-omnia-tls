#!/bin/sh
# This script runs after each call to acme.sh; for either success or failure

# Remove firewall rules we set up earlier; use the comment to ensure only our rules are removed
iptables -D input_rule -p tcp --dport 80 -j ACCEPT -m comment --comment "acme.sh" 2> /dev/null
ip6tables -D input_rule -p tcp --dport 80 -j ACCEPT -m comment --comment "acme.sh" 2> /dev/null
