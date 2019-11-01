#!/bin/bash
compose_setup() {
  docker-compose up -d ngrok 
  sleep 5
  export URL=$(curl $(docker port ngrok 4040)/api/tunnels | python3 -c "import sys, json; print(json.load(sys.stdin)['tunnels'][0]['public_url'])")
  export TOKEN=${token}
  export MONGO_CONNECTION_STRING="${mongo_connection_string}"
  echo $${URL}
  docker-compose build
  docker-compose up -d
  curl $${URL}
}

if [ ! -z $1 ]; then
  cd ~
  git clone https://github.com/liamniou/rutracker_notifier && cd rutracker_notifier
  compose_setup
  echo "0 */9 * * * cd /home/ubuntu/rutracker_notifier && docker-compose down && bash /home/ubuntu/setup_1.sh" >> mycron
  echo "10 * * * * curl localhost:5000/check_subscription_updates" >> mycron
  crontab mycron
  rm mycron
else
  cd /home/ubuntu/rutracker_notifier
  compose_setup
fi
