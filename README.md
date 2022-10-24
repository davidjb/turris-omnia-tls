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

1. Run the `install.sh` script and answer the questions:

       /srv/turris-omnia-tls/install.sh

1. Alternatively, the answer to the questions can be provided via environment
   variables for non-interactive/scripted use (check the source of `install.sh`
   for a current list of supported variables):

       TOT_EMAIL="foo@example.com" TOT_FQDN="turris.example.com" /srv/turris-omnia-tls/install.sh

## Uninstallation

Note that this will not touch issued certificates, which will be left in place
under `/etc/lighttpd/certs`. Also, `acme.sh` related state information will be
left untouched under the `/srv/turris-omnia-tls/var/` hierarchy.

1. Run the `uninstall.sh` script to uninstall modifications performed by the
   `install.sh` script:

       /srv/turris-omnia-tls/uninstall.sh

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
    git pull --recurse-submodules
    ./install.sh
   
## License

MIT. See LICENSE.txt.
