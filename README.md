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

* Uses [Acme.sh](https://github.com/acmesh-official/acme.sh) client for free TLS certificates from [Let's Encrypt](https://letsencrypt.org/)
* Uses hook scripts to simplify issue and renewal process
* Opportunistically opens and closes firewall port 80
* Restarts lighttpd to deploy certificates
* Configures lighttpd for TLSv1.3 only following the [Mozilla SSL Configuration
  Generator](https://ssl-config.mozilla.org/).
* Disables lighttpd from running insecurely on port 80

  * HSTS handles the odd case where you forget or are too lazy to type in the
    `https://` at the start.  Just load the `https://` URL once and your browser
    will remember for you forever.

## Installation

This installs the project and files in `/srv`, which is the default path for
external storage on a Turris device, but you can install wherever you'd like.

1. Download this project:

       opkg install git-http
       git clone https://github.com/davidjb/turris-omnia-tls.git /srv/turris-omnia-tls

1. Determine the latest version of `acme.sh` by checking
   https://github.com/acmesh-official/acme.sh/releases.  Note the release
   version (which is the tag name); you'll use it in the next step,
   substituting for `[VERSION]`.

1. Install `acme.sh` client and its dependency, `socat`; taking care to
   substitute `[VERSION]` and `[YOUREMAIL]` with correct values:

       opkg install socat
       git clone https://github.com/acmesh-official/acme.sh -b [VERSION] /srv/acme.sh
       cd /srv/acme.sh
       ./acme.sh --install --home /srv/.acme.sh --nocron --email [YOUREMAIL]
       ./acme.sh --set-default-ca --home /srv/.acme.sh --server letsencrypt

1. Disable the existing SSL configuration by removing the
   `lighttpd-https-cert` package:

       opkg remove lighttpd-https-cert

1. Stop `updater` from automatically reinstalling the `lighttpd-https-cert`
   package:

       cp /srv/turris-omnia-tls/updater_custom.lua /etc/updater/conf.d/no-upstream-ssl.lua

1. Make sure the `lighttpd-mod-openssl` package is installed:

       opkg install lighttpd-mod-openssl

1. Lighttpd needs to stop listening on port 80 so modify
   `/etc/lighttpd/conf.d/90-turris-root.conf` to comment out these lines:

       $SERVER["socket"] == "*:80"    {  }
       $SERVER["socket"] == "[::]:80" {   }

1. Stop lighttpd; we will enable it again shortly:

       /etc/init.d/lighttpd stop

1. Issue the certificate, taking care to specify your FQDN in place of
   `[YOUR.DOMAIN.COM]`:

       /srv/turris-omnia-tls/cert-issue.sh [YOUR.DOMAIN.COM]

1. Reconfigure lighttpd with the supplied custom configuration:

       cp /srv/turris-omnia-tls/lighttpd_custom.conf /etc/lighttpd/conf.d/40-ssl-acme-enable.conf

   Inside this file, replace the `domain.example.com` placeholders with your
   FQDN. You can do this automatically by running the following command,
   again taking care to specify your FQDN in place of `[YOUR.DOMAIN.COM]`:

       sed -i 's/domain.example.com/[YOUR.DOMAIN.COM]/g' /etc/lighttpd/conf.d/40-ssl-acme-enable.conf

1. Restart `lighttpd`:

       /etc/init.d/lighttpd start

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

## Upgrading acme.sh

Run the following; after `fetch`ing, you'll see the latest version tag:

    cd /srv/acme.sh
    git fetch
    git checkout [VERSION]
    ./acme.sh --install --home /srv/.acme.sh --nocron

## License

MIT. See LICENSE.txt.
