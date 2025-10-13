#!/bin/bash
PORT=$1
INPUT=$2

echo "Calling app on port ${PORT} with input ${INPUT}"

curl -X POST http://192.168.49.2:${PORT}/send \
     -H "Content-Type: application/json" \
     -d "{\"value\": ${INPUT}}"