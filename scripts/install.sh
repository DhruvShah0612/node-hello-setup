#!/bin/bash
set -e

cd /var/www/html

# optional cleanup (safe)
rm -rf node_modules

# check files exist
ls -la

# set permissions
chmod -R 755 /var/www/html

# install dependencies
npm install
