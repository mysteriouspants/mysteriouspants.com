#!/bin/sh

rsync -avz _site/ xpm@mysteriouspants.com:/var/www/www.mysteriouspants.com/
ssh xpm@mysteriouspants.com chmod -R ugo+rx /var/www/www.mysteriouspants.com
