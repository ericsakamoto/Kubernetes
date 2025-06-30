#!/bin/bash
curl -X POST http://192.168.49.2:32099/send \
     -H "Content-Type: application/json" \
     -d '{"value": 30}'