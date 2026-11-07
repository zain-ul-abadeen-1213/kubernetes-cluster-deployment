#!/usr/bin/env bash
# Create the local kind cluster and deploy the Zain Tech Automation Solutions
# web app into it. Run from anywhere: bash scripts/setup.sh
set -e

cd "$(dirname "$0")/.."

echo "==> Creating kind cluster 'zaintech' (1 control-plane + 2 workers)..."
kind create cluster --name zaintech --config kind-config.yaml

echo "==> Creating namespace..."
kubectl apply -f namespace.yaml

echo "==> Applying manifests (ConfigMap, Deployment, Service, HPA)..."
kubectl apply -f configmap.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f hpa.yaml

echo "==> Waiting for the deployment to roll out..."
kubectl rollout status deployment/zaintech-web -n zaintech --timeout=180s

echo ""
echo "Done. The site is live at: http://localhost:30080"
echo "Check the pods with:       kubectl get pods -n zaintech"
