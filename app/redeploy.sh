#!/bin/bash

# This script redeploys the Kubernetes applications
kubectl rollout restart deployment app-a -n skmt
kubectl rollout restart deployment app-b -n skmt
