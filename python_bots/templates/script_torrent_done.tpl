#!/bin/bash

send_message_to_bot() {
  curl -X POST -H 'Content-Type: application/json' -d '{"chat_id": "${tg_id}", "text": "'"\$1"'"}' https://api.telegram.org/bot${bot_token}/sendMessage
}

destroy() {
  send_message_to_bot "Trigger workspace for destroy"
  curl \
    --header "Authorization: Bearer ${terraform_token}" \
    --header "Content-Type: application/vnd.api+json" \
    --request POST \
    --data '{"data":{"attributes":{"is-destroy":"true","message":"Destroy from instance"},"type":"runs","relationships":{"workspace":{"data":{"type":"workspaces","id":"${terraform_workspace_id}"}}}}}' \
    https://app.terraform.io/api/v2/runs
}

REMOTE_DIR="/mnt/hdd/downloads"
LOG_FILE="/tmp/transmission.log"

find \$TR_TORRENT_DIR -name "*.part" -type f -delete

send_message_to_bot "\$TR_TORRENT_NAME transfer to Plex has been started"

ssh -i ~/.ssh/id_rsa admin@${storage_host} -p ${storage_port} "echo '\$TR_TORRENT_DIR transfer started' >> \$LOG_FILE"
scp -P ${storage_port} -i ~/.ssh/id_rsa -r \$TR_TORRENT_DIR admin@${storage_host}:\$REMOTE_DIR 1>>\$LOG_FILE 2>>\$LOG_FILE && echo "\$TR_TORRENT_DIR successfully copied" >>\$LOG_FILE 2>&1
ssh -i ~/.ssh/id_rsa admin@${storage_host} -p ${storage_port} "echo '\$TR_TORRENT_DIR transfer finished' >> \$LOG_FILE"

ssh -i ~/.ssh/id_rsa admin@${storage_host} -p ${storage_port} "bash /Users/admin/Plex/script.sh"

send_message_to_bot "\$TR_TORRENT_NAME transfer to Plex has been finished"
rm -rf \$TR_TORRENT_DIR

# sh /tmp/remove_finished.sh Doesn't work due to some permissions issue

DIR="/tmp/downloads"
if [ -d "\$DIR" ]
then
	if [ "\$(ls -A \$DIR)" ]; then
    send_message_to_bot "Downloads dir is not empty, skipping destruction"
	else
    destroy
	fi
else
	echo "Directory \$DIR not found."
fi
