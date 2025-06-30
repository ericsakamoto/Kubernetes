#!/bin/bash

# Login to Docker Hub
docker login

# Build and push App A
docker build -t ericsakamoto/app-a:latest -f frontend/Dockerfile .
docker push ericsakamoto/app-a:latest

# Build and push App B
docker build -t ericsakamoto/app-b:latest -f backend/Dockerfile .
docker push ericsakamoto/app-b:latest
