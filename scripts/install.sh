#!/bin/bash
set -e

cd /var/www/html

# remove old files safely (hidden files pan)
rm -rf ./* ./.??*

# permissions
chmod -R 755 /var/www/html

# install dependencies
npm install
