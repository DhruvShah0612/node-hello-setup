#!/bin/bash
set -e

echo "INSTALL START"

# permission fix
chown -R ubuntu:ubuntu /var/www/html

cd /var/www/html

# check files exist
ls -la

# install dependencies
sudo -u ubuntu npm install

echo "INSTALL DONE"
