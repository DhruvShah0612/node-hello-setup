#!/bin/bash
# set -e

# cd /home/ubuntu/app

# export PATH=/usr/bin:/usr/local/bin:$PATH

# echo "Current user: $(whoami)"
# echo "Node path: $(which node)"
# echo "PM2 path: $(which pm2)"

# pm2 delete node-app || true
# pm2 start index.js --name node-app
# pm2 save


#!/bin/bash
set -e

echo "===== START STAGE START ====="

cd /home/ubuntu/app

export PATH=/usr/bin:/usr/local/bin:$PATH

echo "User: $(whoami)"
echo "Node: $(which node)"
echo "PM2: $(which pm2)"

# Stop old app (safe)
pm2 delete node-app || true

# Start new app
pm2 start index.js --name node-app

# Save PM2 process
pm2 save

echo "===== START STAGE COMPLETE ====="
