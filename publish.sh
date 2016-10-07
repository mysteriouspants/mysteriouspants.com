#!/bin/sh

REMOTE_USER=xpm
REMOTE_HOST=mysteriouspants.com
REMOTE_PATH=/var/www/www.mysteriouspants.com

bundle exec jekyll build

rsync -avz _site/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/
ssh ${REMOTE_USER}@${REMOTE_HOST} chmod -R 644 ${REMOTE_PATH}
