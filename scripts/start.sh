#!/bin/bash
set -e

echo "START"

cd /home/ubuntu/app

whoami
ls -la

pm2 delete node-app || true
pm2 start index.js --name node-app
pm2 save

echo "DONE"
