#!/bin/bash
cd ~
git clone https://github.com/liamniou/rutracker_notifier && cd rutracker_notifier
docker-compose run -e TOKEN=${token} -d ngrok
URL=$(curl $(docker port ngrok 4040)/api/tunnels | python -c "import sys, json; print json.load(sys.stdin)['tunnels'][0]['public_url']")
docker-compose run -e TOKEN=${token} -e URL=$${URL} -d bot
