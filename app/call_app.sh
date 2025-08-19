#!/bin/bash
PORT=$1

curl -X POST http://192.168.49.2:${PORT}/send
     -H "Content-Type: application/json" \
     -d '{"value": 30}'