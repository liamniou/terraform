#!/bin/bash

mkdir /bots && cd /bots

# Shared budget bot
git clone https://github.com/liamniou/shared_budget_bot.git && cd shared_budget_bot
wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=${pickle_gdrive_id}' -O ./app/token.pickle
cat > ./app/config << EOL
[telegram]
token = ${shared_budget_bot_token}
person_1_tg_id = ${person_1_tg_id}
person_2_tg_id = ${person_2_tg_id}

[sheets]
scope = ${scope}
spreadsheet_id = ${spreadsheet_id}
sheet_id = ${sheet_id}
EOL
docker build -t shared_budget_bot_image .
docker run -dit -e TZ=Europe/Minsk --restart unless-stopped --name=shared_budget_bot -v shared_budget_bot_app:/app shared_budget_bot_image
cd /bots

# Transmission daemon setup
add-apt-repository -y ppa:transmissionbt/ppa
apt-get -y update
apt-get -y install transmission-cli transmission-common transmission-daemon
cat > /etc/transmission-daemon/settings.json << EOL
${transmission_settings}
EOL

# Prerequisites for script-torrents-done
mkdir -p /var/lib/transmission-daemon/.ssh
ssh-keyscan -p ${storage_port} -H ${storage_host} >> /var/lib/transmission-daemon/.ssh/known_hosts
cat > /var/lib/transmission-daemon/.ssh/id_rsa << EOL
${id_rsa}
EOL
chmod 600 /var/lib/transmission-daemon/.ssh/id_rsa
chown -R debian-transmission:debian-transmission /var/lib/transmission-daemon/.ssh
echo "scp -P 2809 -i ~/.ssh/id_rsa -r $TR_TORRENT_DIR pi@lestar.ddns.net:/mnt/hdd/downloads 1>> /tmp/scp.log 2>> /tmp/out.log && echo '$TR_TORRENT_DIR successfully copied' >> /tmp/out.log 2>&1 && rm -rf $TR_TORRENT_DIR" > /tmp/script.sh
chmod +x /tmp/script.sh
/etc/init.d/transmission-daemon reload

# Transmission remote bot
git clone https://github.com/liamniou/transmission_mgmt_bot && cd transmission_mgmt_bot
cat > ./app/config << EOL
[telegram]
token = ${transmission_management_bot_token}
[transmission]
transmission_host = ${transmission_host}
transmission_port = ${transmission_port}
transmission_user = ${transmission_user}
transmission_password = ${transmission_password}
transmission_download_dir = ${transmission_download_dir}
EOL
docker build -t transmission_mgmt_bot_image .
docker run -dit --restart unless-stopped --net=host --name=transmission_mgmt_bot -v transmission_mgmt_bot_app:/app transmission_mgmt_bot_image

cd /bots
