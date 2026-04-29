#!/bin/bash
cd /home/ubuntu/app

npm install -g pm2
pm2 stop all || true
pm2 start index.js --name node-app
