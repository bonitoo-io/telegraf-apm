#!/bin/bash

set -ex

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

docker rm -f demo-rails-app || true
docker rm -f demo-java-app || true
docker rm -f telegraf-apm || true
docker rm -f postgres-demo || true
docker rm -f redis-demo || true

docker network rm apm_network || true
docker network create -d bridge apm_network --subnet 192.168.1.0/24 --gateway 192.168.1.1 || true

./influxdb-restart.sh
./telegraf/build-telegraf.sh

docker run -d --name telegraf-apm \
  --network apm_network \
  -p 8200:8200 \
  --volume="$(pwd)/telegraf/telegraf.conf:/etc/telegraf/telegraf.conf:ro" \
  telegraf-apm

docker run -d --name postgres-demo \
  --network apm_network \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  postgres

docker run -d --name redis-demo \
  --network apm_network \
  -p 6379:6379 \
  redis

#### attach redis cli client
#docker run -it --name my-redis-cli --network apm_network --rm redis redis-cli -h redis-demo -p 6379

## build rails demo app image
docker -v  build ./demo-rails-app -t demo-rails-app
docker -v  build ./demo-java-app -t demo-java-app

docker run -d --name demo-java-app \
  --network apm_network \
  -p 8080:8080 \
  -e "JAVA_OPTS=-Xmx128m -Delastic.apm.server_urls=http://telegraf-apm:8200"  \
  --env ELASTIC_APM_APPLICATION_PACKAGES=io.bonitoo \
  demo-java-app:latest

docker run -d --name=demo-rails-app \
  --network apm_network \
  -p 3000:3000 \
  --env ELASTIC_APM_SERVER_URL=http://telegraf-apm:8200 \
  --env POSTGRES_HOST=postgres-demo \
  --env REDIS_HOST=redis-demo \
  demo-rails-app:latest

## initialize database
docker exec -it demo-rails-app rails db:migrate:reset
