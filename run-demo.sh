#!/bin/bash

set -ex

ELASTIC_VERSION=7.6.1
#KIBANA_VERSION=7.6.1

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

docker rm -f elasticsearch || true
docker rm -f kibana || true
docker rm -f apm-server || true
docker rm -f demo-rails-app || true

docker network rm apm_network || true
docker network create -d bridge apm_network --subnet 192.168.1.0/24 --gateway 192.168.1.1

docker pull docker.elastic.co/elasticsearch/elasticsearch:${ELASTIC_VERSION}
docker pull docker.elastic.co/kibana/kibana:${ELASTIC_VERSION}
docker pull docker.elastic.co/apm/apm-server:${ELASTIC_VERSION}

docker run --detach --name elasticsearch  \
  -p 9200:9200 -p 9300:9300 --network apm_network \
  -e "discovery.type=single-node" \
  docker.elastic.co/elasticsearch/elasticsearch:7.6.1

docker run --detach --name kibana\
  -p 5601:5601 --network apm_network \
  docker.elastic.co/kibana/kibana:${ELASTIC_VERSION}

docker run --detach --name=apm-server \
  --user=apm-server \
  --network apm_network \
  -p 8200:8200 \
  --volume="$(pwd)/apm-server.docker.yml:/usr/share/apm-server/apm-server.yml:ro" \
  docker.elastic.co/apm/apm-server:${ELASTIC_VERSION} \
  --strict.perms=false -e \
  -E output.elasticsearch.hosts=["elasticsearch:9200"]
#  -E apm-server.rum.enabled=true \
#  -E apm-server.rum.event_rate.limit=300 \
#  -E apm-server.rum.event_rate.lru_size=1000 \
#  -E apm-server.rum.allow_origins=['*'] \
#  -E apm-server.rum.library_pattern="node_modules|bower_components|~" \
#  -E apm-server.rum.exclude_from_grouping="^/webpack"
#  -E apm-server.rum.source_mapping.enabled=true \
#  -E apm-server.rum.source_mapping.cache.expiration=5m \
#  -E apm-server.rum.source_mapping.index_pattern="apm-*-sourcemap*"


docker -v  build ./demo-rails-app -t demo-rails-app

docker run --rm --detach --name=demo-rails-app \
  --network apm_network \
  -p 3000:3000 \
  --env ELASTIC_APM_SERVER_URL=http://apm-server:8200 \
  demo-rails-app:latest




