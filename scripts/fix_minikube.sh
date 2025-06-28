#!/bin/bash

echo "🔧 Minikube Troubleshooting and Recovery Script"

# Function to check Minikube status
check_minikube_status() {
    echo "🔍 Checking Minikube status..."
    minikube status
    return $?
}

# Function to check kubectl connectivity
check_kubectl() {
    echo "🔍 Checking kubectl connectivity..."
    kubectl cluster-info --request-timeout=10s
    return $?
}

# Function to restart Minikube
restart_minikube() {
    echo "🔄 Restarting Minikube cluster..."
    
    # Stop Minikube
    minikube stop || true
    
    # Delete if corrupted
    if [ "$1" == "hard-reset" ]; then
        echo "⚠️ Performing hard reset..."
        minikube delete || true
    fi
    
    # Start Minikube with proper configuration
    minikube start \
        --driver=docker \
        --memory=3900 \
        --cpus=2 \
        --disk-size=20g \
        --kubernetes-version=v1.28.0 \
        --wait=true
    
    # Wait for cluster to be ready
    echo "⏳ Waiting for cluster to be ready..."
    kubectl wait --for=condition=Ready nodes --all --timeout=300s
}

# Main troubleshooting logic
echo "🚀 Starting Minikube troubleshooting..."

# Check if Minikube is running
if ! check_minikube_status; then
    echo "❌ Minikube is not running properly"
    restart_minikube
else
    echo "✅ Minikube is running"
fi

# Check kubectl connectivity
if ! check_kubectl; then
    echo "❌ kubectl connectivity failed, attempting restart..."
    restart_minikube
    
    # Retry kubectl after restart
    if ! check_kubectl; then
        echo "❌ kubectl still failing, performing hard reset..."
        restart_minikube "hard-reset"
        
        # Final check
        if ! check_kubectl; then
            echo "❌ Unable to establish kubectl connectivity"
            exit 1
        fi
    fi
fi

echo "✅ Minikube and kubectl are ready!"

# Enable required addons
echo "🔧 Enabling required addons..."
minikube addons enable metrics-server || echo "Failed to enable metrics-server"
minikube addons enable ingress || echo "Failed to enable ingress"

# Display cluster info
echo "📊 Cluster Information:"
kubectl cluster-info
kubectl get nodes
kubectl get namespaces

echo "✅ Minikube troubleshooting completed successfully!"
