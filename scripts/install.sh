#!/bin/bash
set -e

# permission fix
chown -R ubuntu:ubuntu /var/www/html

cd /var/www/html

# install dependencies
sudo npm install

