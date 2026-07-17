#!/bin/bash
# deploy.sh
set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Kubernetes Starter — Deploy"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Step 1 — Start minikube
echo ""
echo "[1/7] Starting minikube..."
minikube start --memory=2048 --cpus=2
minikube addons enable ingress
minikube addons enable metrics-server

# Step 2 — Build image inside minikube
echo ""
echo "[2/7] Building image inside minikube..."
eval $(minikube docker-env)
docker build -t kavibhat/hotel-quote-api:latest .

# Step 3 — Apply manifests in order
echo ""
echo "[3/7] Creating namespace..."
kubectl apply -f namespace.yaml

echo ""
echo "[4/7] Creating ConfigMap..."
kubectl apply -f configmap.yaml

echo ""
echo "[5/7] Creating Deployment..."
kubectl apply -f deployment.yaml

echo ""
echo "[6/7] Creating Service..."
kubectl apply -f service.yaml

echo ""
echo "[7/7] Creating Ingress..."
kubectl apply -f ingress.yaml

# Wait for rollout
echo ""
echo "Waiting for deployment..."
kubectl rollout status deployment/quote-api \
  -n hotel-quotes --timeout=60s

# Show results
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Deploy Complete! ✅"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
kubectl get all -n hotel-quotes

# Port forward for easy access
echo ""
echo "Starting port-forward..."
echo "Access at: http://localhost:3000"
kubectl port-forward svc/quote-api 3000:80 \
  -n hotel-quotes
