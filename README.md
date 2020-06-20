# Let's Encrypt Certificates for Turris Omnia

This config utilises the [Acme.sh](https://github.com/Neilpang/acme.sh) client
to issue a Let's Encrypt certificate for use wtih the Turris Omnia web interface.

Adapted in part from the instructions at
<https://doc.turris.cz/doc/en/public/letencrypt_turris_lighttpd> for improved
security and simplicity.

This may also work for other OpenWrt devices but has not yet been tested in such
an environment.

## Key features

* Uses [Acme.sh](https://github.com/Neilpang/acme.sh) client for free TLS certificates.
* Uses hook scripts to simplify issue and renewal process
* Automatically formats certificates for lighttpd
* Restarts lighttpd to deploy certificates
* Adds TLS improvements to lighttpd following [Mozilla's config
  generator](https://mozilla.github.io/server-side-tls/ssl-config-generator/).
* Opportunistically opens and closes firewall port 80 on Turris Omnia
* Runs lighttpd on a separate HTTP port to port 80. This avoids needing to
  stop and start lighttpd but also fully avoids the issue of inadvertently
  exposing the UI to the public Internet as the firewall is opened and closed.

  * HSTS handles the odd case where you forget or are too lazy to type in the
    `https://` at the start.  Just load the `https://` URL once and your browser
    will remember for you forever.

## Installation

This installs the project and files in `/srv`, which is the default path for
external storage on a Turris device, but you can install wherever you'd like.

1. Download this project:

       opkg install git-http
       git clone https://github.com/davidjb/turris-omnia-tls.git /srv/turris-omnia-tls
       
1. Deterime the latest version of `acme.sh` by checking
   https://github.com/acmesh-official/acme.sh/releases.  Note the release version (which is the
   tag name); you'll use it in the next step, substituting for `[VERSION]`.

1. Install `acme.sh` client and its dependency, `socat`:

       opkg install socat
       git clone https://github.com/acmesh-official/acme.sh -b [VERSION] /srv/acme.sh
       cd /srv/acme.sh
       ./acme.sh --install --home /srv/.acme.sh --nocron

1. Disable the existing SSL configuration:

       mv /etc/lighttpd/conf.d/ssl-enable.conf /etc/lighttpd/conf.d/ssl-enable.conf.disabled

1. Lighttpd needs to stop listening on port 80 so modify
   `/etc/lighttpd/lighttpd.conf` to comment out this line:

       $SERVER["socket"] == "[::]:80" {   }

   For note, the later custom configuration changes the IPv4 port.

1. Stop lighttpd; we will enable it again shortly:

       /etc/init.d/lighttpd stop

1. Issue the certificate and reconfigure lighttpd:

       /srv/turris-omnia-tls/cert-issue.sh domain.example.com

       cp /srv/turris-omnia-tls/lighttpd_custom.conf /etc/lighttpd/conf.d/
       # Edit this file and replace `domain.example.com` with your FQDN
       sed -i 's/domain.example.com/your.domain.com/g' /etc/lighttpd/conf.d/lighttpd_custom.conf

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

## License

MIT. See LICENSE.txt.
