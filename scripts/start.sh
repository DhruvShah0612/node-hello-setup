#!/bin/bash
set -e

cd /home/ubuntu/app

export PATH=/usr/bin:/usr/local/bin:$PATH

echo "Current user: $(whoami)"
echo "Node path: $(which node)"
echo "PM2 path: $(which pm2)"

pm2 delete node-app || true
pm2 start index.js --name node-app
pm2 save
