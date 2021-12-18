#!/bin/bash

curl -X POST -H 'Content-Type: application/json' -d '{"chat_id": "${personal_tg_id}", "text": "DO Instance has been started"}' https://api.telegram.org/bot${best_wines_tg_token}/sendMessage

mkdir /bots && cd /bots

# Best wines bot
git clone https://github.com/liamniou/best_wines_sweden.git && cd best_wines_sweden
apt update && apt install python3 && apt install -y python3-pip
python3 -m pip install -r app/requirements.txt

apt install -y gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget

TELEGRAM_BOT_TOKEN=${best_wines_tg_token} TELEGRAM_CHAT_ID=${best_wines_chat_id} CHROME_TIMEOUT=${chrome_timeout} python3 app/best_wines_sweden.py || true

WORKSPACE_ID=${workspace_id} TF_CLOUD_TOKEN=${tf_cloud_token} IS_DESTROY=true python3 trigger_terraform_workspace.py

curl -X POST -H 'Content-Type: application/json' -d '{"chat_id": "${personal_tg_id}", "text": "DO Instance has been triggered for destroy"}' https://api.telegram.org/bot${best_wines_tg_token}/sendMessage