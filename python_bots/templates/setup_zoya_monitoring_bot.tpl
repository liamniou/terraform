#!/bin/bash
cd ~
git clone https://github.com/liamniou/zoya_monitoring_bot.git && cd zoya_monitoring_bot
cp /tmp/zoya.pickle ./app/token.pickle
cat > ./app/config << EOL
[telegram]
token = ${token}
[sheets]
scope = ${scope}
spreadsheet_id = ${spreadsheet_id}
sheet_id = ${sheet_id}
EOL
docker build -t zoya_monitoring_bot_image .
docker run -dit --restart unless-stopped --name=zoya_monitoring_bot -v zoya_monitoring_bot_app:/app zoya_monitoring_bot_image
