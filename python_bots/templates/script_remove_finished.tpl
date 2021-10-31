#!/bin/bash

send_message_to_bot() {
  curl -X POST -H 'Content-Type: application/json' -d '{"chat_id": "${tg_id}", "text": "'"\$1"'"}' https://api.telegram.org/bot${bot_token}/sendMessage
}

### Destroy instance if no active torrents
SERVER="localhost:9091 --auth ${transmission_user}:${transmission_password}"

# Which torrent states should be removed at 100% progress.
DONE_STATES="Seeding Stopped Finished Idle"

# Use transmission-remote to get the torrent list from transmission-remote.
TORRENT_LIST=\$(/usr/bin/transmission-remote \$SERVER --list | sed -e '1d' -e '\$d' | awk '{print \$1}' | sed -e 's/[^0-9]*//g')

# Iterate through the torrents.
for TORRENT_ID in \$TORRENT_LIST
do
    INFO=\$(/usr/bin/transmission-remote \$SERVER --torrent "\$TORRENT_ID" --info)
    echo -e "Processing #\$TORRENT_ID: \"\$(echo "\$INFO" | sed -n 's/.*Name: \(.*\)/\1/p')\"..."
    # To see the full torrent info, uncomment the following line.
    # echo "\$INFO"
    PROGRESS=\$(echo "\$INFO" | sed -n 's/.*Percent Done: \(.*\)%.*/\1/p')
    STATE=\$(echo "\$INFO" | sed -n 's/.*State: \(.*\)/\1/p')

    # If the torrent is 100% done and the state is one of the done states.
    for DONE_STATE in \$DONE_STATES
    do
      if [[ "\$PROGRESS" == "100" ]] && [[ "\$DONE_STATE" == "\$STATE" ]]; then
        send_message_to_bot "Torrent #\$TORRENT_ID is done. Removing torrent from list."
        /usr/bin/transmission-remote \$SERVER --torrent "\$TORRENT_ID" --remove
      else
        echo "Torrent #\$TORRENT_ID is \$PROGRESS% done with state \"\$STATE\". Ignoring."
      fi
    done
done

TORRENT_LIST=\$(/usr/bin/transmission-remote \$SERVER --list | sed -e '1d' -e '\$d' | awk '{print \$1}' | sed -e 's/[^0-9]*//g')

if [ -z "\$TORRENT_LIST" ]
then
  send_message_to_bot "There are no active torrents, trigger workspace for destroy"
  curl \
    --header "Authorization: Bearer ${terraform_token}" \
    --header "Content-Type: application/vnd.api+json" \
    --request POST \
    --data '{"data":{"attributes":{"is-destroy":"true","message":"Destroy from instance"},"type":"runs","relationships":{"workspace":{"data":{"type":"workspaces","id":"${terraform_workspace_id}"}}}}}' \
    https://app.terraform.io/api/v2/runs
fi
