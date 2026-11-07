#!/usr/bin/env bash
# Rolling update: swap the served page from Version 1 to Version 2.
# The ConfigMap content changes, then the deployment restarts so every pod
# picks up the new page — with zero downtime.
set -e

cd "$(dirname "$0")/.."

echo "==> Applying the Version 2 ConfigMap..."
kubectl apply -f configmap-v2.yaml

echo "==> Restarting the deployment (rolling update)..."
kubectl rollout restart deployment/zaintech-web -n zaintech

echo "==> Waiting for the rollout to finish..."
kubectl rollout status deployment/zaintech-web -n zaintech --timeout=180s

echo ""
echo "Done. Refresh http://localhost:30080 — the page now shows Version 2."
echo "To roll back: kubectl rollout undo deployment/zaintech-web -n zaintech"
