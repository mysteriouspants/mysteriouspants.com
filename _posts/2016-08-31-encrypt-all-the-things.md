---
title:    "Let's Encrypt on Nginx Setup"
date:     2016-08-31 5:21
---

Encryption is a thing now, 314, proliferated to the point that Google
will downrank site which do not have it. I've never exactly cared who,
if anyone, reads this site, but I thought I'd give Let's Encrypt a try -
if for no better reason than because I'd like to use HTTP2 on a web app
I'm writing.

These notes are really for my benefit, though it might benefit you as
well.

First, install Let's Encrypt.

    apt install letsencrypt

For every domain, modify the virtual server definition to look like this:

    vim /etc/nginx/sites-available/mysteriouspants.com
      # a reflector domain that just redirects to www.,
      # and serves .well-known files
      server {
        listen 80;
        server_name mysteriouspants.com;
        access_log off;

        root /var/www/empty;

        location /.well-known {
          root /var/www/letsencrypt;
          try_files $uri /dev/null =404;
        }

        location / {
          return 301 https://$host$request_uri;
        }
      }
    vim /etc/nginx/sites-available/www.mysteriouspants.com
      server {
        listen 80;
        server_name www.mysteriouspants.com;
        access_log off;

        root /var/www/empty;

        location /.well-known {
          root /var/www/letsencrypt;
          try_files $uri /dev/null =404;
        }

        location / {
          return 301 https://$host$request_uri;
        }
      }

      server {
        listen 443 ssl http2;
        server_name www.mysteriouspants.com;
        access_log off;

        ssl_certificate /etc/letsencrypt/live/mysteriouspants.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/mysteriouspants.com/privkey.pem;

        root /var/www/www.mysteriouspants.com;
      }
    service nginx reload

Make some directories. The `empty` directory in particular is for the
root of the redirection mirrors.

    mkdir /var/www/empty
    mkdir /var/www/letsencrypt

Actually grab your first SSL certificate. It will ask you to accept a
EULA, then it will populate `/var/www/letsencrypt` with some challenge
files. Their servers will ask your domains for those files to prove that
you control the domains - so they're not just handing out certificates
willy-nilly.

    letsencrypt certonly --webroot -w /var/www/letsencrypt \
      -d mysteriouspants.com \
      -d www.mysteriouspants.com

This command should complete with no errors, if it does, your Nginx
configuration is likely messed up.

At this point, your web pages are actually SSL'd now that your SSL
certificates exist. Harden up your Nginx server by adding this set of
ciphers I totally didn't just pull off some webpage.

    vim /etc/nginx/nginx.conf
      ssl_ciphers EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;

Finally, Let's Encrypt certificates are only good for 90 days, so it's
best to renew them. They suggest twice a day, which is super easy to do
via a simple cron task.

    vim /etc/cron.d/letencrypt
      0 0,12 * * * * letsencrypt renew

And there you have it.
