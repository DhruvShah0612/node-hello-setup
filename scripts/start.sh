#!/bin/bash
set -e

cd /var/www/html

pm2 delete node-app || true
pm2 start index.js --name node-app
pm2 save
