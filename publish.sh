#!/bin/sh

set -x
set -e

REMOTE_USER=xpm
REMOTE_HOST=mysteriouspants.com
REMOTE_PATH=/var/www/www.mysteriouspants.com

bundle install
bundle exec jekyll build

ssh ${REMOTE_USER}@${REMOTE_HOST} sudo chown xpm:xpm ${REMOTE_PATH}
rsync -avz _site/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/
ssh ${REMOTE_USER}@${REMOTE_HOST} "find ${REMOTE_PATH} -type d -exec chmod 755 {} \;"
ssh ${REMOTE_USER}@${REMOTE_HOST} "find ${REMOTE_PATH} -type f -exec chmod 644 {} \;"
