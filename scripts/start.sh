#!/bin/bash
set -e

cd /home/ubuntu/app

export PATH=/usr/bin:/usr/local/bin:$PATH

pm2 delete node-app || true
pm2 start index.js --name node-app
pm2 save
