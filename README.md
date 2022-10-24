# Let's Encrypt Certificates for Turris Omnia

This config utilises the [Acme.sh](https://github.com/acmesh-official/acme.sh) client
to issue [Let's Encrypt](https://letsencrypt.org/) certificates for use wtih
the Turris Omnia web interface.

If you're looking to issue and manage just a single certificate within OpenWrt, see
the official, packaged-based solution at https://github.com/acmesh-official/acme.sh/wiki/How-to-run-on-OpenWRT.

Adapted in part from the instructions at
<https://doc.turris.cz/doc/en/public/letencrypt_turris_lighttpd> for improved
security and simplicity; this setup should work fine for other OpenWrt devices
using lighttpd.

## Key features

* Uses the [acme.sh](https://github.com/acmesh-official/acme.sh) client to
  obtain free TLS certificates from [Let's Encrypt](https://letsencrypt.org/)
* Uses hook scripts to simplify issue and renewal process
* Opportunistically opens and closes firewall port 80
* Restarts lighttpd to deploy certificates
* Configures lighttpd for TLSv1.3 only following the [Mozilla SSL Configuration
  Generator](https://ssl-config.mozilla.org/).
* Configures lighttpd to upgrade unencrypted connections.
* Configures the [HSTS 
header](https://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security).

## Installation

This installs the project and files in `/srv`, which is the default path for
external storage on a Turris device, but you can install wherever you'd like.

1. Download this project, including the `acme.sh` submodule:

       opkg install git-http
       git clone --recurse-submodules https://github.com/davidjb/turris-omnia-tls.git /srv/turris-omnia-tls

1. Install the `acme.sh` client and its dependency, `socat`; taking care to
   substitute `[YOUREMAIL]` with correct values:

       opkg install socat
       cd /srv/turris-omnia-tls/acme.sh
       ./acme.sh --install --home /srv/.acme.sh --no-profile --nocron --email [YOUREMAIL]
       ./acme.sh --set-default-ca --home /srv/.acme.sh --server letsencrypt

1. Disable the existing SSL configuration by removing the
   `lighttpd-https-cert` package:

       opkg remove lighttpd-https-cert

1. Stop `updater` from automatically reinstalling the `lighttpd-https-cert`
   package:

       cp /srv/turris-omnia-tls/updater_custom.lua /etc/updater/conf.d/no-upstream-ssl.lua

1. Make sure the `lighttpd-mod-openssl` package is installed:

       opkg install lighttpd-mod-openssl

1. Reconfigure lighttpd to support the `acme` webroot, taking care to replace
   the %TOT_BASEDIR% placeholder inside the template file:

       sed -e "s|%TOT_BASEDIR%|/srv/turris-omnia-tls|g" /srv/turris-omnia-tls/lighttpd_webroot.conf > /etc/lighttpd/conf.d/39-acme-webroot.conf

1. Restart `lighttpd`:

       /etc/init.d/lighttpd restart

1. Issue the certificate, taking care to specify your FQDN in place of
   `[HOSTNAME.DOMAIN.COM]`:

       /srv/turris-omnia-tls/cert-issue.sh [HOSTNAME.DOMAIN.COM]

1. Reconfigure lighttpd to enable TLS and to use the new certificates, taking
   care to replace the %TOT_FQDN% and %TOT_HOSTNAME% placeholders inside the
   template file:

       sed \
           -e "s|%TOT_FQDN%|turris.example.com|g" \
           -e "s|%TOT_HOSTNAME%|turris|g" \
           /srv/turris-omnia-tls/lighttpd_tls.conf > /etc/lighttpd/conf.d/40-acme-tls.conf

1. Restart `lighttpd` again:

       /etc/init.d/lighttpd restart

1. Add crontab entry for renewal; pick a random minute and hour:

       echo '34 0 * * * /srv/turris-omnia-tls/cert-renew.sh > /dev/null' >> /etc/crontabs/root

   The renewal process will automatically re-use the settings for certificates
   that were issued.

## Issuing more certificates

Run the following:

    /srv/turris-omnia-tls/cert-issue.sh extra.example.com

Note that this will automatically configure relevant hooks to run before and after certificate
issuance.  If you want to adjust this behaviour your can either copy and customise the command
inside `cert-issue.sh` before you run it the first time or go and modify the configuration
that `acme.sh` generates in `/etc/lighttpd/certs/extra.example.com/extra.example.com.conf`,
where `extra.example.com` is the name of your domain.

## Upgrading turris-omnia-tls and acme.sh

Run the following:

    cd /srv/turris-omnia-tls
    git pull
    git submodule update --remote acme.sh
    cd acme.sh
    ./acme.sh --install --home /srv/.acme.sh --no-profile --nocron

## License

MIT. See LICENSE.txt.
