#!/bin/bash
set -euo pipefail

cd /apps/terraform-node-pm2
npm i
pm2 startOrReload /apps/ecosystem.config.json
