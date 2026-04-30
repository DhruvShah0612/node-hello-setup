#!/bin/bash
set -e

cd /home/ubuntu/app

pm2 delete node-app || true
pm2 start index.js --name node-app
pm2 save

