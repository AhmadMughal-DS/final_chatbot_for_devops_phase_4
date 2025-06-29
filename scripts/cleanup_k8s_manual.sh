#!/bin/bash

echo "🛑 DevOps Chatbot - Manual Cleanup Script"
echo "=========================================="

echo "This script will remove the DevOps Chatbot from Kubernetes"
echo "⚠️  WARNING: This will permanently delete the deployment!"
echo ""

read -p "Are you sure you want to proceed? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cleanup cancelled."
    exit 1
fi

echo "🧹 Starting cleanup process..."

# Remove HPA
echo "📈 Removing Horizontal Pod Autoscaler..."
kubectl delete -f k8s-hpa.yaml --ignore-not-found=true

# Remove Service
echo "🌐 Removing Service..."
kubectl delete -f k8s-service.yaml --ignore-not-found=true

# Remove Deployment
echo "🚀 Removing Deployment..."
kubectl delete -f k8s-deployment.yaml --ignore-not-found=true

# Remove PVC
echo "💾 Removing Persistent Volume Claims..."
kubectl delete -f k8s-pvc.yaml --ignore-not-found=true

echo ""
echo "✅ Cleanup completed!"
echo ""
echo "📊 Remaining resources:"
kubectl get pods -l app=devops-chatbot 2>/dev/null || echo "No pods found"
kubectl get services | grep devops-chatbot 2>/dev/null || echo "No services found"

echo ""
echo "💡 To redeploy the application, run:"
echo "   kubectl apply -f k8s-pvc.yaml"
echo "   kubectl apply -f k8s-deployment.yaml"
echo "   kubectl apply -f k8s-service.yaml"
echo "   kubectl apply -f k8s-hpa.yaml"
