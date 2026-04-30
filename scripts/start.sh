#!/bin/bash
set -e

echo "START SCRIPT"

cd /home/ubuntu/app

# IMPORTANT DEBUG
ls -la

# fail if no package.json
if [ ! -f package.json ]; then
  echo "ERROR: package.json not found"
  exit 1
fi

npm install

pm2 delete node-app || true
pm2 start index.js --name node-app
pm2 save

echo "APP STARTED"
