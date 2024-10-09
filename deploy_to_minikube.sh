#!/bin/sh

# Exit immediately if a command exits with a non-zero status.
set -e

# Check if Minikube is running
if ! minikube status | grep -q "Running"; then
    echo "Minikube is not running. Starting Minikube..."
    minikube start
fi

# Set Docker environment to use Minikube's Docker daemon
eval $(minikube docker-env)

# Apply Kubernetes manifests
echo "Deploying services to Minikube..."
kubectl apply -f infra/gateway.yaml
kubectl apply -f infra/go.yaml
kubectl apply -f infra/php.yaml
kubectl apply -f infra/python.yaml

# Wait for deployments to be ready
echo "Waiting for deployments to be ready..."
kubectl wait --for=condition=available deployment --all --timeout=300s

# Get the URL for the gateway service
echo "Getting URL for gateway service..."
minikube service gateway-service --url

echo "Deployment complete! You can access your services using the URL above."