#!/bin/bash
set -e

echo "===== DEPLOY START ====="

# permission fix
chown -R ubuntu:ubuntu /var/www/html

cd /var/www/html

# 🧹 CLEAN OLD FILES
echo "Cleaning old files..."
rm -rf /var/www/html/*

echo "Old files removed"

# 📦 CHECK EMPTY DIR
ls -la

# install dependencies
sudo npm install

echo "===== INSTALL DONE ====="
