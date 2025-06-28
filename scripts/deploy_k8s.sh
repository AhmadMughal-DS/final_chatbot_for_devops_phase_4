#!/bin/bash

echo "🚀 Starting Kubernetes Deployment for DevOps Chatbot..."

# Set Minikube Docker environment
echo "Setting up Minikube Docker environment..."
eval $(minikube docker-env)

# Build Docker image
echo "Building Docker image..."
docker build -t devops-chatbot:latest .

# Verify image is built
echo "Verifying Docker image..."
docker images | grep devops-chatbot

# Enable metrics server for HPA
echo "Enabling metrics server..."
minikube addons enable metrics-server

# Apply Kubernetes manifests
echo "Applying PersistentVolumeClaims..."
kubectl apply -f k8s-pvc.yaml

echo "Waiting for PVCs to be ready..."
kubectl wait --for=condition=Bound pvc/chatbot-app-data-pvc --timeout=60s
kubectl wait --for=condition=Bound pvc/chatbot-frontend-pvc --timeout=60s

echo "Applying Deployment..."
kubectl apply -f k8s-deployment.yaml

echo "Applying Services..."
kubectl apply -f k8s-service.yaml

echo "Applying HPA..."
kubectl apply -f k8s-hpa.yaml

# Wait for deployment to be ready
echo "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/devops-chatbot-deployment

# Show status
echo "📊 Deployment Status:"
kubectl get pods -l app=devops-chatbot
kubectl get services
kubectl get hpa

# Get access URLs
echo "🌐 Access URLs:"
echo "NodePort: http://$(minikube ip):30080"
minikube service devops-chatbot-loadbalancer --url

echo "✅ Kubernetes Deployment completed successfully!"
