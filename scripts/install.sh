#!/bin/bash
set -e

echo "INSTALL START"

rm -rf /home/ubuntu/app/*
mkdir -p /home/ubuntu/app

# permissions fix
chown -R ubuntu:ubuntu /home/ubuntu/app

cd /home/ubuntu/app

# node install
if ! command -v node > /dev/null; then
  curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
  apt-get install -y nodejs
fi

# pm2 install
if ! command -v pm2 > /dev/null; then
  npm install -g pm2
fi

echo "INSTALL DONE"
