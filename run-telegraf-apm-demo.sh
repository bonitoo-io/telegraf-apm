#!/bin/bash

set -ex

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

docker rm -f demo-rails-app || true
docker rm -f demo-java-app || true
docker rm -f telegraf-apm || true

docker network rm apm_network || true
docker network create -d bridge apm_network --subnet 192.168.1.0/24 --gateway 192.168.1.1 || true

#./influxdb-restart.sh
#./telegraf/build-telegraf.sh

docker run -d --name telegraf-apm \
  --network apm_network \
  -p 8200:8200 \
  --volume="$(pwd)/telegraf/telegraf.conf:/etc/telegraf/telegraf.conf:ro" \
  telegraf-apm

## build rails demo app image
docker -v  build ./demo-rails-app -t demo-rails-app
docker -v  build ./demo-java-app -t demo-java-app


docker run -d --name demo-java-app \
  --network apm_network \
  -p 8080:8080 \
  -e "JAVA_OPTS=-Xmx128m -Delastic.apm.server_urls=http://telegraf-apm:8200"  \
  demo-java-app:latest

docker run -d --name=demo-rails-app \
  --network apm_network \
  -p 3000:3000 \
  --env ELASTIC_APM_SERVER_URL=http://telegraf-apm:8200 \
  demo-rails-app:latest
