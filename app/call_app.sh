#!/bin/bash
SERVICE_NAME="app-a"
NAMESPACE="skmt"
INPUT=$1

# Get Minikube IP
MINIKUBE_IP=$(minikube ip)

# Get NodePort for the service
PORT=$(kubectl get svc ${SERVICE_NAME} -n ${NAMESPACE} -o jsonpath='{.spec.ports[0].nodePort}')

echo "Calling app '${SERVICE_NAME}' on ${MINIKUBE_IP}:${PORT} with input ${INPUT}"

curl -X POST http://${MINIKUBE_IP}:${PORT}/send \
     -H "Content-Type: application/json" \
     -d "{\"value\": ${INPUT}}"