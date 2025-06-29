#!/bin/bash

# System Restart Recovery Script for DevOps Chatbot
# This script recovers Minikube and redeploys the application after a system restart

echo "🔄 DevOps Chatbot - System Restart Recovery"
echo "==========================================="
echo "$(date): Starting recovery process..."

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to wait with timeout
wait_with_timeout() {
    local timeout=$1
    local command=$2
    local description=$3
    
    echo "⏳ $description (timeout: ${timeout}s)..."
    
    for i in $(seq 1 $timeout); do
        if eval $command >/dev/null 2>&1; then
            echo "✅ $description - Success!"
            return 0
        fi
        echo -n "."
        sleep 1
    done
    
    echo ""
    echo "❌ $description - Timeout after ${timeout}s"
    return 1
}

# Step 1: Check prerequisites
echo ""
echo "🔍 Step 1: Checking prerequisites..."
echo "===================================="

if ! command_exists docker; then
    echo "❌ Docker not found. Please install Docker first."
    exit 1
fi

if ! command_exists kubectl; then
    echo "❌ kubectl not found. Please install kubectl first."
    exit 1
fi

if ! command_exists minikube; then
    echo "❌ minikube not found. Please install minikube first."
    exit 1
fi

echo "✅ All prerequisites found"

# Step 2: Check current status
echo ""
echo "🔍 Step 2: Checking current status..."
echo "===================================="

echo "📊 Current Minikube status:"
minikube status || echo "Minikube is not running"

echo ""
echo "📊 Current Docker status:"
if systemctl is-active --quiet docker; then
    echo "✅ Docker service is running"
else
    echo "❌ Docker service is not running"
    echo "🔄 Starting Docker service..."
    sudo systemctl start docker
    sleep 5
    if systemctl is-active --quiet docker; then
        echo "✅ Docker service started successfully"
    else
        echo "❌ Failed to start Docker service"
        exit 1
    fi
fi

# Step 3: Check if API server is responding
echo ""
echo "🔍 Step 3: Testing Kubernetes API connectivity..."
echo "==============================================="

if kubectl cluster-info --request-timeout=5s >/dev/null 2>&1; then
    echo "✅ Kubernetes API server is responding"
    echo "🎉 Cluster appears to be healthy, checking application..."
    
    # Check if application is running
    if kubectl get pods -l app=devops-chatbot --no-headers 2>/dev/null | grep -q "Running"; then
        echo "✅ Application is already running!"
        kubectl get pods -l app=devops-chatbot
        kubectl get services devops-chatbot-service
        
        # Show access information
        echo ""
        echo "🌐 Application Access Information:"
        NODE_PORT=$(kubectl get service devops-chatbot-service -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "30080")
        
        if curl -s --max-time 3 http://169.254.169.254/latest/meta-data/public-ipv4 >/dev/null 2>&1; then
            PUBLIC_IP=$(curl -s --max-time 5 http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "3.14.84.26")
            PRIVATE_IP=$(curl -s --max-time 5 http://169.254.169.254/latest/meta-data/local-ipv4 2>/dev/null || echo "172.31.0.45")
            echo "📡 Public URL: http://$PUBLIC_IP:$NODE_PORT"
            echo "🏠 Private URL: http://$PRIVATE_IP:$NODE_PORT"
        else
            MINIKUBE_IP=$(minikube ip 2>/dev/null || echo "localhost")
            echo "🔗 Application URL: http://$MINIKUBE_IP:$NODE_PORT"
        fi
        
        echo "🎉 Recovery complete - application is already running!"
        exit 0
    else
        echo "⚠️ Cluster is running but application is not deployed"
        echo "🔄 Will redeploy application..."
    fi
else
    echo "❌ Kubernetes API server is not responding"
    echo "🔄 Need to restart Minikube..."
fi

# Step 4: Stop and clean up any hanging processes
echo ""
echo "🧹 Step 4: Cleaning up hanging processes..."
echo "========================================="

echo "🔄 Stopping any hanging Minikube processes..."
sudo pkill -f minikube || true
sudo pkill -f kubectl || true
sleep 5

echo "🔄 Stopping current Minikube cluster..."
minikube stop || true
sleep 10

# Step 5: Restart Minikube with conservative settings
echo ""
echo "🚀 Step 5: Restarting Minikube..."
echo "================================"

echo "🔄 Starting Minikube with conservative settings..."
minikube start \
    --driver=docker \
    --memory=2048 \
    --cpus=2 \
    --disk-size=10g \
    --delete-on-failure \
    --force

if [ $? -ne 0 ]; then
    echo "❌ Standard Minikube start failed, trying minimal config..."
    minikube delete || true
    sleep 10
    minikube start --driver=docker --memory=1536 --cpus=1 --force
fi

# Step 6: Wait for cluster to be ready
echo ""
echo "⏳ Step 6: Waiting for cluster to be ready..."
echo "============================================"

if ! wait_with_timeout 120 "kubectl cluster-info --request-timeout=5s" "API server to respond"; then
    echo "❌ Cluster failed to start properly"
    echo "🔍 Debugging information:"
    minikube status || true
    minikube logs || true
    exit 1
fi

echo "✅ Kubernetes cluster is ready!"

# Step 7: Enable required addons
echo ""
echo "🔧 Step 7: Enabling required addons..."
echo "===================================="

echo "📊 Enabling metrics-server for HPA..."
minikube addons enable metrics-server || echo "Metrics server addon failed"

# Step 8: Redeploy the application
echo ""
echo "🚀 Step 8: Redeploying the application..."
echo "======================================="

# Check if we're in the right directory
if [ ! -f "k8s-deployment.yaml" ]; then
    echo "🔍 Looking for deployment files..."
    if [ -d "final_chatbot_for_devops_phase_4" ]; then
        cd final_chatbot_for_devops_phase_4
    elif [ -f "../k8s-deployment.yaml" ]; then
        cd ..
    else
        echo "❌ Cannot find deployment files. Please run this script from the project directory."
        exit 1
    fi
fi

echo "📁 Current directory: $(pwd)"
echo "📋 Available Kubernetes files:"
ls -la k8s-*.yaml 2>/dev/null || echo "No k8s files found"

# Clean up any existing deployment
echo "🧹 Cleaning up any existing deployment..."
kubectl delete -f k8s-hpa.yaml --ignore-not-found=true
kubectl delete -f k8s-service.yaml --ignore-not-found=true
kubectl delete -f k8s-deployment.yaml --ignore-not-found=true
kubectl delete -f k8s-pvc.yaml --ignore-not-found=true

sleep 10

# Check if Docker image exists in Minikube
echo "🔍 Checking for existing Docker image..."
eval $(minikube docker-env)
if docker images | grep -q devops-chatbot; then
    echo "✅ DevOps chatbot image found in Minikube"
    docker images | grep devops-chatbot
else
    echo "❌ DevOps chatbot image not found, need to rebuild..."
    
    # Build the Docker image
    echo "🏗️ Building Docker image..."
    if [ -f "Dockerfile" ]; then
        docker build -t devops-chatbot:latest . || {
            echo "❌ Failed to build Docker image"
            exit 1
        }
        echo "✅ Docker image built successfully"
    else
        echo "❌ Dockerfile not found"
        exit 1
    fi
fi

# Deploy the application
echo "📦 Deploying application components..."

echo "🗄️ Applying PersistentVolumeClaims..."
kubectl apply -f k8s-pvc.yaml

echo "🚢 Applying Deployment..."
kubectl apply -f k8s-deployment.yaml

echo "🌐 Applying Service..."
kubectl apply -f k8s-service.yaml

echo "📈 Applying HPA..."
kubectl apply -f k8s-hpa.yaml

# Step 9: Wait for deployment to be ready
echo ""
echo "⏳ Step 9: Waiting for deployment to be ready..."
echo "==============================================="

echo "⏳ Waiting for pods to start..."
if ! wait_with_timeout 180 "kubectl get pods -l app=devops-chatbot --no-headers | grep -q Running" "pods to be running"; then
    echo "❌ Pods failed to start properly"
    echo "🔍 Pod status:"
    kubectl get pods -l app=devops-chatbot
    echo "🔍 Pod details:"
    kubectl describe pods -l app=devops-chatbot
    echo "📝 Pod logs:"
    kubectl logs -l app=devops-chatbot --tail=50 || echo "No logs available"
    exit 1
fi

echo "✅ Application deployment is ready!"

# Step 10: Show final status and access information
echo ""
echo "🎉 Step 10: Recovery Complete!"
echo "============================="

echo "📊 Final deployment status:"
kubectl get pods -l app=devops-chatbot
kubectl get services devops-chatbot-service
kubectl get hpa devops-chatbot-hpa 2>/dev/null || echo "HPA not available"

echo ""
echo "🌐 Application Access Information:"
NODE_PORT=$(kubectl get service devops-chatbot-service -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "30080")

# Detect environment and show appropriate URLs
if curl -s --max-time 3 http://169.254.169.254/latest/meta-data/public-ipv4 >/dev/null 2>&1; then
    # AWS EC2
    PUBLIC_IP=$(curl -s --max-time 5 http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "3.14.84.26")
    PRIVATE_IP=$(curl -s --max-time 5 http://169.254.169.254/latest/meta-data/local-ipv4 2>/dev/null || echo "172.31.0.45")
    
    echo "☁️ AWS EC2 Environment:"
    echo "📡 Public URL: http://$PUBLIC_IP:$NODE_PORT"
    echo "🏠 Private URL: http://$PRIVATE_IP:$NODE_PORT"
    echo ""
    echo "⚠️ Make sure Security Group allows port $NODE_PORT"
    
    # Test connectivity
    echo "🧪 Testing local connectivity..."
    if curl -s --max-time 10 "http://$PRIVATE_IP:$NODE_PORT" >/dev/null 2>&1; then
        echo "✅ Application is responding locally!"
    else
        echo "❌ Application not responding locally (may still be starting up)"
    fi
else
    # Local Minikube
    MINIKUBE_IP=$(minikube ip 2>/dev/null || echo "localhost")
    echo "🖥️ Local Minikube Environment:"
    echo "🔗 Application URL: http://$MINIKUBE_IP:$NODE_PORT"
fi

echo ""
echo "✅ System restart recovery completed successfully!"
echo "🎉 Your DevOps Chatbot is now running again!"
echo ""
echo "💡 Useful commands for the future:"
echo "  - Check status: kubectl get pods -l app=devops-chatbot"
echo "  - View logs: kubectl logs -l app=devops-chatbot"
echo "  - Restart app: kubectl rollout restart deployment/devops-chatbot-deployment"
echo "  - Stop app: kubectl delete -f k8s-deployment.yaml"
