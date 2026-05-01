#!/bin/bash
set -e
echo "===== START APP ====="

cd /var/www/html

# Kill any leftover PM2
pm2 delete node-app || true
pm2 kill || true

# Start fresh with new code
pm2 start index.js --name node-app
pm2 save
pm2 startup || true

echo "Current PM2 status:"
pm2 status

echo "===== APP RUNNING ====="
