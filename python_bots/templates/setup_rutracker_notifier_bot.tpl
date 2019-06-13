#!/bin/bash
cd ~
git clone https://github.com/liamniou/rutracker_notifier && cd rutracker_notifier
cat > ./app/config.py << EOL
token = "${token}"
database_name = "${database_name}"
rutracker_login = "${rutracker_login}"
rutracker_password = "${rutracker_password}"
EOL
docker build -t rutracker_notifier_image .
docker run -dit --restart unless-stopped --name=rutracker_notifier -v rutracker_notifier_bot_app:/app rutracker_notifier_image