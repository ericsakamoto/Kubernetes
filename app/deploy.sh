#!/bin/bash
minikube start --driver=docker

kubectl create namespace skmt

kubectl apply -f backend/app-b-deployment.yaml
kubectl apply -f frontend/app-a-deployment.yaml


