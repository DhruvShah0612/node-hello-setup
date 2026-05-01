#!/bin/bash
set -e
echo "===== DEPLOY START ====="

# Step 1: Stop old PM2 process FIRST (before deleting files)
pm2 delete node-app || true
pm2 kill || true
echo "PM2 stopped"

# Step 2: Go to destination
cd /var/www/html

# Step 3: Remove old files (now safe because PM2 is stopped)
find /var/www/html -mindepth 1 ! -name 'node_modules' -exec rm -rf {} + 2>/dev/null || true
echo "Old files removed (node_modules kept for speed)"

# Step 4: Fix permissions
chown -R ubuntu:ubuntu /var/www/html

# Step 5: Show what was deployed
echo "Listing new files..."
ls -la

# Step 6: Install dependencies
npm install
echo "npm install done"

echo "===== INSTALL DONE ====="
