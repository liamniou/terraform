#!/bin/bash

compose_setup() {
  docker-compose up -d ngrok 
  sleep 5
  URL=$(curl $(docker port ngrok 4040)/api/tunnels | python3 -c "import sys, json; print(json.load(sys.stdin)['tunnels'][0]['public_url'].replace('http://', 'https://'))")
  echo "URL=$${URL}" > ./.env
  echo "TOKEN=${token}" >> ./.env
  echo "MONGO_CONNECTION_STRING=${mongo_connection_string}" >> ./.env
  docker-compose build
  docker-compose up -d
  sleep 5
  curl $${URL}
}

if [ ! -z $1 ]; then
  cd ~
  git clone https://github.com/liamniou/rutracker_notifier && cd rutracker_notifier
  compose_setup
  echo "PATH=/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin" >> mycron
  echo "SHELL=/bin/bash" >> mycron
  echo "0 */7 * * * /home/ubuntu/setup_1.sh >> /var/log/cron.log" >> mycron
  echo "10 * * * * curl localhost:5000/check_subscription_updates" >> mycron
  crontab mycron
  rm mycron
else
  cd /home/ubuntu/rutracker_notifier
  docker-compose down
  compose_setup
fi
