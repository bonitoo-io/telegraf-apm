#!/usr/bin/env bash
set -ex

docker rm -f influxdb_v2 || true
SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

INFLUXDB_V2_IMAGE=quay.io/influxdb/influx:nightly
#INFLUXDB_V2_IMAGE=quay.io/influxdb/influxdb:2.0.0-beta

docker pull ${INFLUXDB_V2_IMAGE} || true
docker run \
       --detach \
       --name influxdb_v2 \
       --network apm_network \
       --volume "${SCRIPT_PATH}":/usr/src/app/ \
       --publish 9999:9999 \
       ${INFLUXDB_V2_IMAGE}

echo "Wait to start InfluxDB 2.0"
wget -S --spider --tries=20 --retry-connrefused --waitretry=5 http://localhost:9999/metrics

echo
echo "Post onBoarding request, to setup initial user (my-user@my-password), org (my-org) and bucketSetup (my-bucket)"
echo
curl -i -X POST http://localhost:9999/api/v2/setup -H 'accept: application/json' \
    -d '{
            "username": "my-user",
            "password": "my-password",
            "org": "my-org",
            "bucket": "my-bucket",
            "token": "my-token"
        }'

docker exec -it influxdb_v2 influx -t my-token bucket create -o my-org  -r 72h --name apm_metricset
docker exec -it influxdb_v2 influx -t my-token bucket create -o my-org  -r 24h --name apm_transaction
docker exec -it influxdb_v2 influx -t my-token bucket create -o my-org  -r 168h --name apm_error
