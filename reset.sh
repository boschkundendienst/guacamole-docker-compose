#!/bin/bash
#####################################################################################
#
# version            date              comment
# 0.2                2024/08/15        fix SQL base delete when changing base password
#
#####################################################################################
echo "This will delete your existing database (./data/)"
echo "          delete your drive files       (./drive/)"
echo "          delete your recordings        (./recordings/)"
echo "          delete your certs files       (./nginx/ssl/)"
echo "          delete your int files         (./init/)"
echo "          delete your extensions files  (./extensions/)"
echo ""
read -p "Are you sure? [Y/n]" -n 1 -r
echo ""   # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]; then # do dangerous stuff
 chmod -R +x -- ./init
 sudo rm -r -f ./data/ ./drive/ ./recordings/ ./nginx/ssl/ ./init/ ./extensions/
fi
