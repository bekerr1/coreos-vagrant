#!/bin/bash

echo "cURLing API service version"
curl http://127.0.0.1:8080/version

echo "cURLing for created pods"
curl -s localhost:10255/pods | jq -r '.items[].metadata.name'
