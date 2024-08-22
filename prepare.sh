#!/bin/sh
#####################################################################################
#
# version            date              comment
# 0.9                2024/08/15        add TOTP + history-recording and folders
#
#####################################################################################
# version : guacamole 1.5.5
GUAC_VERSION="1.5.5"

#
# check if docker is running
if ! (docker ps >/dev/null 2>&1)
then
	echo "/!\ docker daemon not running, will exit here!"
	exit
fi

# Creation folders
echo "++ Creating folders"
mkdir ./init >/dev/null 2>&1
mkdir -p ./nginx/ssl >/dev/null 2>&1
chmod -R +x ./init
mkdir ./extensions >/dev/null 2>&1
mkdir ./recordings >/dev/null 2>&1
echo "=> done"

# SQL database initialization
echo "++ Creating ./init/initdb.sql"
docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --postgresql > ./init/initdb.sql
echo "=> done"

# Downloading extensions
echo "++ Download extensions"
FILE="guacamole-auth-totp-$GUAC_VERSION.tar.gz"
URL="https://apache.org/dyn/closer.lua/guacamole/$GUAC_VERSION/binary/$FILE"
LOCAL_PATH="./extensions/$FILE"
if test -f "$LOCAL_PATH"; then
    echo "/!\ The $LOCAL_PATH file already exists."
else
    echo "/!\ The $LOCAL_PATH file does not exist, download begins..."
    wget -c -P ./extensions $URL
fi

FILE="guacamole-history-recording-storage-$GUAC_VERSION.tar.gz"
URL="https://apache.org/dyn/closer.lua/guacamole/$GUAC_VERSION/binary/$FILE"
LOCAL_PATH="./extensions/$FILE"
if test -f "$LOCAL_PATH"; then
    echo "/!\ The $LOCAL_PATH file already exists."
else
    echo "/!\ The $LOCAL_PATH file does not exist, download begins..."
    wget -c -P ./extensions $URL
fi
echo "=> done"

# Creating certificates
echo "++ Creating SSL certificates"
openssl req -nodes -newkey rsa:2048 -new -x509 -keyout nginx/ssl/self-ssl.key -out nginx/ssl/self.cert -subj '/C=DE/ST=BY/L=Hintertupfing/O=Dorfwirt/OU=Theke/CN=www.createyourown.domain/emailAddress=docker@createyourown.domain'
echo "/!\ You can use your own certificates by placing the private key in nginx/ssl/self-ssl.key and the cert in nginx/ssl/self.cert"
echo "=> done"
