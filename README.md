# Let's Encrypt Certificates for Turris Omnia

This config utilises the Acme.sh client to issue a Let's Encrypt certificate
for use wtih the Turris Omnia web interface.

Adapted in part from the instructions at
<https://doc.turris.cz/doc/en/public/letencrypt_turris_lighttpd> for improved
security and simplicity.

## Key features

* Acme.sh client for free TLS certificates.
* Automatically formats certificates for lighttpd
* Reloads lighttpd to deploy certificates
* Opens and closes firewall to port 80 on Turris Omnia
* Runs lighttpd on a separate HTTP port to port 80. This avoids needing to stop
  and start lighttpd but also avoids the issue of inadvertently exposing the
  UI to the public Internet as the firewall is opened and closed.

  * HSTS handles the odd case where you forget or are lazy to type in the
    `https://` at the start.  Just load the `https://` URL once and your browser
    will remember.

* Adds TLS improvements to lighttpd following [Mozilla's config
  generator](https://mozilla.github.io/server-side-tls/ssl-config-generator/).

## Installation

1. Download this project:

       opkg install git-http
       git clone https://github.com/davidjb/turris-omnia-tls.git /root/turris-omnia-tls

1. Install `acme.sh` client:

       git clone https://github.com/Neilpang/acme.sh.git -b 2.7.6 /root/acme.sh
       /root/acme.sh/acme.sh --install --nocron
       rm -rf /root/acme.sh

1. Disable the existing SSL configuration:

       mv /etc/lighttpd/conf.d/ssl-enable.conf /etc/lighttpd/conf.d/ssl-enable.conf.disabled

1. Lighttpd needs to stop listening on port 80 so modify
   `/etc/lighttpd/lighttpd.conf` to comment out this line:

       $SERVER["socket"] == "[::]:80" {   }

   For note, the later custom configuration changes the IPv4 port.

1. Stop lighttpd; we will enable it again shortly:

       /etc/init.d/lighttpd stop
       /root/turris-omnia-tls/cert-issue.sh domain.example.com

       cp lighttpd_custom.conf /etc/lighttpd/conf.d/
       # Edit this file and replace `domain.example.com` with your FQDN
       sed -i 's/domain.example.com/your.domain.com/g' /etc/lighttpd/conf.d/lighttpd_custom.conf

       /etc/init.d/lighttpd start

1. Add crontab entry for renewal; pick a random minute and hour:

       echo '34 0 * * * /root/turris-omnia-tls/cert-renew.sh > /dev/null' >> /etc/crontabs/root

   The renewal process will automatically re-use the settings for certificates
   that were issued.

## License

MIT. See LICENSE.txt.
