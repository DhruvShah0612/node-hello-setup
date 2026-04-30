#!/bin/bash
set -e

echo "INSTALL START"

# clean old app
rm -rf /var/www/html/*
mkdir -p /var/www/html

# permission fix (IMPORTANT 🔥)
chown -R ubuntu:ubuntu /var/www/html

cd /var/www/html

# install dependencies
sudo -u ubuntu npm install

echo "INSTALL DONE"
