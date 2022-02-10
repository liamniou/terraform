#!/bin/bash

send_message_to_bot() {
  curl -X POST -H 'Content-Type: application/json' -d '{"chat_id": "${personal_tg_id}", "text": "'"\$1"'"}' https://api.telegram.org/bot${best_wines_tg_token}/sendMessage
}

destroy() {
  send_message_to_bot "Trigger workspace for destroy"
  curl \
    --header "Authorization: Bearer ${tf_cloud_token}" \
    --header "Content-Type: application/vnd.api+json" \
    --request POST \
    --data '{"data":{"attributes":{"is-destroy":"true","message":"Destroy from instance"},"type":"runs","relationships":{"workspace":{"data":{"type":"workspaces","id":"${workspace_id}"}}}}}' \
    https://app.terraform.io/api/v2/runs
}

# curl -X POST -H 'Content-Type: application/json' -d '{"chat_id": "${personal_tg_id}", "text": "DO Instance has been started"}' https://api.telegram.org/bot${best_wines_tg_token}/sendMessage

send_message_to_bot "DO Instance has been started"

# mkdir /bots && cd /bots

# Best wines bot
# git clone https://github.com/liamniou/best_wines_sweden.git && cd best_wines_sweden

docker run -it \
  --name=best_wines \
  --env=TELEGRAM_BOT_TOKEN=${best_wines_tg_token} \
  --env=TELEGRAM_CHAT_ID=${best_wines_chat_id} \
  --env=CHROME_TIMEOUT=${chrome_timeout} \
  --env=TELEGRAPH_TOKEN=${telegraph_token} \
  liamnou/best_wines_sweden_amd64:7

# WORKSPACE_ID=${workspace_id} TF_CLOUD_TOKEN=${tf_cloud_token} IS_DESTROY=true python3 trigger_terraform_workspace.py
# destroy