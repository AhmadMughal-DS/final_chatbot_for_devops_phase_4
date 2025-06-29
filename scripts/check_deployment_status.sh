#!/bin/bash

echo "📊 DevOps Chatbot - Deployment Status Check"
echo "==========================================="

# Function to check if a resource exists
check_resource() {
    local resource_type=$1
    local resource_name=$2
    local namespace=${3:-default}
    
    if kubectl get $resource_type $resource_name -n $namespace >/dev/null 2>&1; then
        echo "✅ $resource_type/$resource_name is running"
        return 0
    else
        echo "❌ $resource_type/$resource_name is NOT found"
        return 1
    fi
}

echo "🔍 Checking Kubernetes resources..."
echo ""

# Check Deployment
check_resource "deployment" "devops-chatbot-deployment"

# Check Service
check_resource "service" "devops-chatbot-service"

# Check HPA
check_resource "hpa" "devops-chatbot-hpa" 2>/dev/null || echo "⚠️  HPA not available (this is optional)"

# Check PVC
check_resource "pvc" "devops-chatbot-pvc"

echo ""
echo "📋 Detailed Status:"
echo "==================="

# Show pods
echo "🐳 Pods:"
kubectl get pods -l app=devops-chatbot 2>/dev/null || echo "No pods found"

echo ""
echo "🌐 Services:"
kubectl get services devops-chatbot-service 2>/dev/null || echo "Service not found"

echo ""
echo "📈 HPA Status:"
kubectl get hpa devops-chatbot-hpa 2>/dev/null || echo "HPA not configured"

# Get application URL
echo ""
echo "🚀 Application Access:"
if command -v minikube >/dev/null 2>&1; then
    MINIKUBE_IP=$(minikube ip 2>/dev/null)
    NODE_PORT=$(kubectl get service devops-chatbot-service -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
    
    if [ ! -z "$MINIKUBE_IP" ] && [ ! -z "$NODE_PORT" ]; then
        echo "   URL: http://$MINIKUBE_IP:$NODE_PORT"
        
        # Test connectivity
        echo ""
        echo "🔗 Connectivity Test:"
        if curl -s --connect-timeout 5 "http://$MINIKUBE_IP:$NODE_PORT" >/dev/null; then
            echo "✅ Application is accessible!"
        else
            echo "❌ Application is not responding"
        fi
    else
        echo "❌ Could not determine application URL"
    fi
else
    echo "⚠️  Minikube not available - cannot determine external URL"
fi

echo ""
echo "💾 Resource Usage:"
kubectl top pods -l app=devops-chatbot 2>/dev/null || echo "Resource metrics not available"

echo ""
echo "📝 Recent Events:"
kubectl get events --sort-by=.metadata.creationTimestamp | grep devops-chatbot | tail -5 2>/dev/null || echo "No recent events"

echo ""
echo "💡 Commands:"
echo "   To view logs: kubectl logs -l app=devops-chatbot"
echo "   To restart:   kubectl rollout restart deployment/devops-chatbot-deployment"
echo "   To cleanup:   ./scripts/cleanup_k8s_manual.sh"
