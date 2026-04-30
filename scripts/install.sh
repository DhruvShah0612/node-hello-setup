#!/bin/bash
set -e

echo "INSTALL START"

# OLD APP DELETE 🔥
rm -rf /home/ubuntu/app/*
mkdir -p /home/ubuntu/app

# permission fix
chown -R ubuntu:ubuntu /home/ubuntu/app

cd /home/ubuntu/app

# install dependencies
sudo -u ubuntu npm install
# npm install

echo "INSTALL DONE"
