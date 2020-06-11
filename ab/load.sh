#!/usr/bin/env bash
apk add parallel
cat /tmp/urls.txt | parallel "watch -n 5 ab -n 10 -c 1 {}"
