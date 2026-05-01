#!/bin/bash
set -e
echo "===== DEPLOY START ====="

# Stop PM2
pm2 delete node-app || true
pm2 kill || true
echo "PM2 stopped"

cd /var/www/html

# DELETE EVERYTHING including hidden files
rm -rf /var/www/html/*
rm -rf /var/www/html/.[^.]*  2>/dev/null || true
echo "All old files deleted"

# Verify deletion
echo "After delete:"
ls -la /var/www/html/

# Fix permissions
chown -R ubuntu:ubuntu /var/www/html

# Show new files
echo "New deployed files:"
ls -la

# npm install
npm install
echo "===== INSTALL DONE ====="
