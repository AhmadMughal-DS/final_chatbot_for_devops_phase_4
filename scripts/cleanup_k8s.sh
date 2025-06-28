#!/bin/bash

echo "🧹 Starting Kubernetes Cleanup..."

# Delete all Kubernetes resources
echo "Deleting HPA..."
kubectl delete -f k8s-hpa.yaml --ignore-not-found=true

echo "Deleting Services..."
kubectl delete -f k8s-service.yaml --ignore-not-found=true

echo "Deleting Deployment..."
kubectl delete -f k8s-deployment.yaml --ignore-not-found=true

echo "Deleting PVCs..."
kubectl delete -f k8s-pvc.yaml --ignore-not-found=true

# Wait for cleanup
echo "Waiting for cleanup to complete..."
sleep 10

# Remove Docker image
echo "Removing Docker image..."
docker rmi devops-chatbot:latest --force 2>/dev/null || true

# Show final status
echo "📊 Final Status:"
kubectl get all -l app=devops-chatbot
echo "✅ Cleanup completed!"
