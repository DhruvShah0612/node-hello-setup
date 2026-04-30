#!/bin/bash
# set -e

# cd /home/ubuntu/app

# export PATH=/usr/bin:/usr/local/bin:$PATH

# sudo chown -R ubuntu:ubuntu /home/ubuntu/app

# npm install


#!/bin/bash
set -e

echo "===== INSTALL STAGE START ====="

# Ensure directory exists
sudo mkdir -p /home/ubuntu/app

# Fix ownership (IMPORTANT)
sudo chown -R ubuntu:ubuntu /home/ubuntu/app

cd /home/ubuntu/app

# Ensure Node exists
if ! command -v node > /dev/null; then
  echo "Node.js not found. Installing..."
  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi

# Ensure PM2 exists
if ! command -v pm2 > /dev/null; then
  echo "PM2 not found. Installing..."
  sudo npm install -g pm2
fi

# Install dependencies
npm install

echo "===== INSTALL STAGE COMPLETE ====="
