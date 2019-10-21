#!/bin/bash
cd ~
git clone https://github.com/liamniou/shared_budget_bot.git && cd shared_budget_bot
wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=${pickle_gdrive_id}' -O ./app/token.pickle
cat > ./app/config << EOL
[telegram]
token = ${token}
person_1_tg_id = ${person_1_tg_id}
person_2_tg_id = ${person_2_tg_id}

[sheets]
scope = ${scope}
spreadsheet_id = ${spreadsheet_id}
sheet_id = ${sheet_id}
EOL
docker build -t shared_budget_bot_image .
docker run -dit -e TZ=Europe/Minsk --restart unless-stopped --name=shared_budget_bot -v shared_budget_bot_app:/app shared_budget_bot_image
