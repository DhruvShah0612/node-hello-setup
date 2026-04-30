#!/bin/bash
set -e

echo "===== INSTALL STAGE START ====="

# Go to directory
mkdir -p /home/ubuntu/app
cd /home/ubuntu/app

# Fix ownership (safe)
chown -R ubuntu:ubuntu /home/ubuntu/app

# Update packages (IMPORTANT)
sudo apt-get update -y

# Install Node.js if not present
if ! command -v node > /dev/null; then
  echo "Installing Node.js..."
  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi

# Install PM2 if not present
if ! command -v pm2 > /dev/null; then
  echo "Installing PM2..."
  sudo npm install -g pm2
fi

# Install dependencies (safe)
npm install --unsafe-perm

echo "===== INSTALL STAGE COMPLETE ====="
