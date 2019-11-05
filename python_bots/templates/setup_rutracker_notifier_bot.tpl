#!/bin/bash

DC_NOT_DEFINED=1
if hash docker-compose 2>/dev/null; then
  DC_NOT_DEFINED=0
fi;

if [[ ${DC_NOT_DEFINED} > 0 ]]; then
  echo "* docker-compose not defined, make alias"
  docker-compose() {
      /usr/local/bin/docker-compose "$@"
  }
  export -f docker-compose
  docker-compose -v
fi;

compose_setup() {
  docker-compose up -d ngrok 
  sleep 5
  URL=$(curl $(docker port ngrok 4040)/api/tunnels | python3 -c "import sys, json; print(json.load(sys.stdin)['tunnels'][0]['public_url'])")
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
  echo "0 */9 * * * cd /home/ubuntu/rutracker_notifier && docker-compose down && bash /home/ubuntu/setup_1.sh" >> mycron
  echo "10 * * * * curl localhost:5000/check_subscription_updates" >> mycron
  crontab mycron
  rm mycron
else
  cd /home/ubuntu/rutracker_notifier
  docker-compose down
  compose_setup
fi
