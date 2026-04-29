#!/bin/bash
set -e

cd /home/ubuntu/app

# Load environment
export PATH=/usr/bin:/usr/local/bin:$PATH

# Stop old app
/usr/bin/pm2 stop all || true

# Start app
/usr/bin/pm2 start index.js --name node-app

/usr/bin/pm2 save
