#!/bin/bash

destroy() {
  curl \
    --header "Authorization: Bearer ${tf_cloud_token}" \
    --header "Content-Type: application/vnd.api+json" \
    --request POST \
    --data '{"data":{"attributes":{"is-destroy":"true","message":"Destroy from instance"},"type":"runs","relationships":{"workspace":{"data":{"type":"workspaces","id":"${workspace_id}"}}}}}' \
    https://app.terraform.io/api/v2/runs
}

curl -X POST -H 'Content-Type: application/json' -d '{"chat_id": "${personal_tg_id}", "text": "DO Instance has been started"}' https://api.telegram.org/bot${best_wines_tg_token}/sendMessage

docker run -dit \
  --name=best_wines \
  --env=TELEGRAM_BOT_TOKEN=${best_wines_tg_token} \
  --env=TELEGRAM_CHAT_ID=${best_wines_chat_id} \
  --env=TELEGRAPH_TOKEN=${telegraph_token} \
  liamnou/best_wines_sweden_amd64:10

docker wait best_wines

curl -X POST -H 'Content-Type: application/json' -d '{"chat_id": "${personal_tg_id}", "text": "DO Instance has been triggered for destroy"}' https://api.telegram.org/bot${best_wines_tg_token}/sendMessage
destroy
