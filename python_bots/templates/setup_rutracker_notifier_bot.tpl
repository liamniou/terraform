#!/bin/bash
cd ~
git clone https://github.com/liamniou/rutracker_notifier && cd rutracker_notifier
docker-compose up -d ngrok 
sleep 5
export URL=$(curl $(docker port ngrok 4040)/api/tunnels | python3 -c "import sys, json; print(json.load(sys.stdin)['tunnels'][0]['public_url'])")
export TOKEN=${token}
export MONGO_CONNECTION_STRING="${mongo_connection_string}"
echo $${URL}
docker-compose build
docker-compose up -d
curl $${URL}
echo "0 * * * * curl localhost:5000/check_subscription_updates" >> mycron
crontab mycron
rm mycron
