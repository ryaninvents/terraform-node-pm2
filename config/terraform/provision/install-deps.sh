#!/bin/bash
set -euo pipefail

sudo yum -y update
sudo yum -y install epel-release
sudo yum -y install nodejs
sudo npm i -g pm2
sudo mkdir -p /apps
sudo chown -R centos /apps

# Set up pm2 to start on instance reboot
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u centos --hp /home/centos
