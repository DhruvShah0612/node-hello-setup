#!/bin/bash
set -e

pm2 stop node-app || true
pm2 delete node-app || true

cd /var/www/html

pm2 start index.js --name node-app
pm2 save

