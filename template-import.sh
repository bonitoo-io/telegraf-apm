#!/usr/bin/env bash
#
# docker exec influxdb_v2 /usr/src/app/template-import.sh
#

set -e

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

cd "$SCRIPT_PATH"

influx pkg -o my-org -t my-token -f ./apm-template.yml --force true