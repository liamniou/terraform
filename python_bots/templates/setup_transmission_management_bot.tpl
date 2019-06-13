#!/bin/bash
cd ~
git clone https://github.com/liamniou/transmission_mgmt_bot && cd transmission_mgmt_bot
cat > ./app/config << EOL
[telegram]
token = ${token}
[transmission]
transmission_host = ${transmission_host}
transmission_port = ${transmission_port}
transmission_user = ${transmission_user}
transmission_password = ${transmission_password}
transmission_download_dir = ${transmission_download_dir}
EOL
docker build -t transmission_mgmt_bot_image .
docker run -dit --restart unless-stopped --name=transmission_mgmt_bot -v transmission_mgmt_bot_app:/app transmission_mgmt_bot_image
