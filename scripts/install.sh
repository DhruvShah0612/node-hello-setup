#!/bin/bash
set -e

cd /home/ubuntu/app

export PATH=/usr/bin:/usr/local/bin:$PATH

sudo chown -R ubuntu:ubuntu /home/ubuntu/app

npm install
