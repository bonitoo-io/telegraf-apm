#!/usr/bin/env bash
#
# docker exec influxdb_v2 /usr/src/app/template-export.sh
#

set -e

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

cd "$SCRIPT_PATH"

#influx pkg export all -o my-org -f apm-template.yml -t my-token --filter=resourceKind=Dashboard
influx pkg export all -o my-org -f apm-template.yml -t my-token --filter=labelName=apm