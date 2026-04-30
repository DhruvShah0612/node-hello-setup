#!/bin/bash
set -e

echo "===== START APP ====="

cd /var/www/html

# 🔥 HARD RESET PM2
pm2 delete node-app || true
pm2 kill || true

# start fresh
pm2 start index.js --name node-app

pm2 save

echo "===== APP RUNNING ====="
