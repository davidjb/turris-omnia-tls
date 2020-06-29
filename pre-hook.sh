#!/bin/sh

# Update firewall rules to allow access to port 80 from internet to acme.sh
iptables -I input_rule -p tcp --dport 80 -j ACCEPT -m comment --comment "acme.sh" || return 1
ip6tables -I input_rule -p tcp --dport 80 -j ACCEPT -m comment --comment "acme.sh" || return 1
