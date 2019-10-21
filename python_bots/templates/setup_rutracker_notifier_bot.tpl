#!/bin/bash
cd ~
git clone https://github.com/liamniou/rutracker_notifier && cd rutracker_notifier
docker-compose run -e TOKEN=${token} -d bot
