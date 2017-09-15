#!/bin/bash
set -euo pipefail

cd /app
npm i
pm2 start /app/index.js
pm2 save
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u centos --hp /home/centos
