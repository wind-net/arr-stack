#!/bin/bash

# /etc/letsencrypt/renewal-hooks/deploy/caddy.sh
set -e
USER_NAME=arr
DOMAIN=media.example.com
DEST=/data/arr/config/caddy/certs
UID_N=$(id -u $USER_NAME)

install -o $USER_NAME -g $USER_NAME -m 644 /etc/letsencrypt/live/$DOMAIN/fullchain.pem $DEST/fullchain.pem
install -o $USER_NAME -g $USER_NAME -m 600 /etc/letsencrypt/live/$DOMAIN/privkey.pem   $DEST/privkey.pem

runuser -u $USER_NAME -- env XDG_RUNTIME_DIR=/run/user/$UID_N systemctl --user restart caddy