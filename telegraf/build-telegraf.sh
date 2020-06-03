#!/bin/bash

set -ex

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

cd $SCRIPT_PATH

mkdir -p build
cd build

#pull or clone dir
if cd telegraf; then git pull; else git clone git@github.com:bonitoo-io/telegraf.git telegraf; cd telegraf; fi

#switch to branch
git checkout feature/apm-input-plugin
docker rm -f telegraf-apm || true

cd "$SCRIPT_PATH"
docker -v build . -t telegraf-apm








