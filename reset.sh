#!/bin/bash
echo "This will delete your existing database (./data/)"
echo "          delete your recordings        (./record/)"
echo "          delete your drive files       (./drive/)"
echo ""
read -p "Are you sure? " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
 chmod -R +x -- ./init
 sudo rm -r -f ./data/ ./drive/ ./record/
fi
