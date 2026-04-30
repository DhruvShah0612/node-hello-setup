#!/bin/bash
set -e

echo "===== DEPLOY START ====="

cd /var/www/html

# 🔥 CLEAN OLD FILES (IMPORTANT FIX)
rm -rf /var/www/html/*

echo "Old files removed"

# permission fix
chown -R ubuntu:ubuntu .

echo "Listing files..."
ls -la

npm install

echo "===== INSTALL DONE ====="
