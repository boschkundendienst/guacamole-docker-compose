#!/bin/bash
docker-compose rm --stop --force

docker pull traefik:v2.6
docker pull guacamole/guacd
docker pull guacamole/guacamole

# Download and install 2-FA TOTP extension for Guacamole
GUAC_VER=1.4.0
EXTENSION_DIR=./guac_home/extensions

mkdir -p $EXTENSION_DIR
curl -SLo $EXTENSION_DIR/guacamole-auth-totp-$GUAC_VER.tar.gz "https://apache.org/dyn/closer.lua/guacamole/$GUAC_VER/binary/guacamole-auth-totp-$GUAC_VER.tar.gz?action=download"
tar -xzf $EXTENSION_DIR/guacamole-auth-totp-$GUAC_VER.tar.gz -C $EXTENSION_DIR
mv -f $EXTENSION_DIR/guacamole-auth-totp-$GUAC_VER/guacamole-auth-totp-$GUAC_VER.jar $EXTENSION_DIR/.
rm -rf $EXTENSION_DIR/guacamole-auth-totp-$GUAC_VER $EXTENSION_DIR/guacamole-auth-totp-$GUAC_VER.tar.gz
chown root:root $EXTENSION_DIR/guacamole-auth-totp-$GUAC_VER.jar

docker-compose up -d
