#!/bin/bash
set -euo pipefail

sudo yum -y update
sudo yum -y install epel-release
sudo yum -y install nodejs
sudo npm i -g pm2
sudo mkdir -p /app
sudo chown -R centos /app
