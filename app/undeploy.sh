#!/bin/bash
kubectl delete -f backend/app-b-deployment.yaml
kubectl delete -f frontend/app-a-deployment.yaml
kubectl delete -f app-configmap.yaml