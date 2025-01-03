#!/bin/sh

# Update firewall rules to allow access to port 80 from internet to acme.sh
nft insert rule inet fw4 input_wan tcp dport 80 accept comment \"turris-omnia-tls acme.sh\"
