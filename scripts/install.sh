#!/bin/bash
set -e

echo "INSTALL START"

# FIX PERMISSIONS (MAIN FIX 🔥)
chown -R ubuntu:ubuntu /home/ubuntu/app

cd /home/ubuntu/app

# node check
if ! command -v node > /dev/null; then
  curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
  apt-get install -y nodejs
fi

# pm2 check
if ! command -v pm2 > /dev/null; then
  npm install -g pm2
fi

# install deps
sudo -u ubuntu npm install

echo "INSTALL DONE"
