#!/bin/bash

echo "🔧 Minikube Recovery Script - Post System Restart"
echo "================================================="

# Function to check if Minikube API is responding
check_api_server() {
    kubectl cluster-info --request-timeout=5s >/dev/null 2>&1
}

# Function to check Minikube status
check_minikube_status() {
    minikube status >/dev/null 2>&1
}

echo "🔍 Step 1: Checking current Minikube status..."
if check_minikube_status; then
    echo "✅ Minikube is running"
    if check_api_server; then
        echo "✅ API server is responding"
        echo "🎉 Minikube is healthy - no action needed!"
        exit 0
    else
        echo "⚠️ Minikube is running but API server not responding"
    fi
else
    echo "❌ Minikube is not running"
fi

echo ""
echo "🔍 Step 2: Checking Docker daemon..."
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Starting Docker..."
    sudo systemctl start docker
    sudo systemctl enable docker
    sleep 10
    
    if ! docker info >/dev/null 2>&1; then
        echo "❌ Failed to start Docker. Please check Docker installation."
        exit 1
    fi
    echo "✅ Docker is now running"
else
    echo "✅ Docker is running"
fi

echo ""
echo "🔍 Step 3: Checking for existing Minikube cluster..."
minikube status || echo "Minikube status check completed"

echo ""
echo "🚀 Step 4: Starting/Restarting Minikube..."

# Stop any existing Minikube instance
echo "🛑 Stopping existing Minikube instance..."
minikube stop || echo "No running instance to stop"

# Clean up any hanging processes
echo "🧹 Cleaning up processes..."
pkill -f minikube || true
pkill -f kubectl || true
sleep 5

# Start Minikube with appropriate settings for AWS EC2
echo "🚀 Starting Minikube with AWS EC2 optimized settings..."
minikube start \
    --driver=docker \
    --memory=2048 \
    --cpus=2 \
    --disk-size=10g \
    --delete-on-failure \
    --force

if [ $? -ne 0 ]; then
    echo "❌ Failed to start Minikube with standard settings"
    echo "🔄 Trying with minimal configuration..."
    
    minikube delete || true
    sleep 5
    
    minikube start \
        --driver=docker \
        --memory=1536 \
        --cpus=1 \
        --disk-size=8g \
        --force
    
    if [ $? -ne 0 ]; then
        echo "❌ Failed to start Minikube with minimal settings"
        echo "🔍 Checking system resources..."
        echo "Memory:"
        free -h
        echo "Disk:"
        df -h
        echo "Docker:"
        docker info | head -20
        exit 1
    fi
fi

echo ""
echo "⏳ Step 5: Waiting for Minikube to be fully ready..."
sleep 30

# Wait for API server to be ready
API_READY=false
for i in {1..20}; do
    echo "🔍 API server check attempt $i/20..."
    
    if check_api_server; then
        echo "✅ API server is responding!"
        API_READY=true
        break
    else
        echo "⏳ Waiting for API server... (attempt $i/20)"
        sleep 10
    fi
done

if [ "$API_READY" = false ]; then
    echo "❌ API server failed to start after extended wait"
    echo "🔍 Minikube status:"
    minikube status
    echo "🔍 Minikube logs:"
    minikube logs | tail -50
    exit 1
fi

echo ""
echo "🔍 Step 6: Verifying cluster components..."
kubectl get nodes
kubectl get pods -n kube-system

echo ""
echo "🔍 Step 7: Checking for existing application deployment..."
if kubectl get deployment devops-chatbot-deployment >/dev/null 2>&1; then
    echo "✅ DevOps chatbot deployment found!"
    echo "📊 Current status:"
    kubectl get pods -l app=devops-chatbot
    kubectl get services devops-chatbot-service
    
    # Get NodePort for access information
    NODE_PORT=$(kubectl get service devops-chatbot-service -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "30080")
    
    # Check if we're on AWS EC2
    if curl -s --max-time 3 http://169.254.169.254/latest/meta-data/public-ipv4 >/dev/null 2>&1; then
        PUBLIC_IP=$(curl -s --max-time 5 http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "3.14.84.26")
        PRIVATE_IP=$(curl -s --max-time 5 http://169.254.169.254/latest/meta-data/local-ipv4 2>/dev/null || echo "172.31.0.45")
        
        echo ""
        echo "🌐 Application Access Information:"
        echo "=================================="
        echo "📡 Public URL: http://$PUBLIC_IP:$NODE_PORT"
        echo "🏠 Private URL: http://$PRIVATE_IP:$NODE_PORT"
        echo ""
        echo "🔥 Make sure AWS Security Group allows port $NODE_PORT inbound traffic!"
        
        # Test local connectivity
        echo ""
        echo "🧪 Testing local connectivity..."
        if curl -s --max-time 10 "http://localhost:$NODE_PORT" >/dev/null 2>&1; then
            echo "✅ Application is responding locally on port $NODE_PORT"
        elif curl -s --max-time 10 "http://$PRIVATE_IP:$NODE_PORT" >/dev/null 2>&1; then
            echo "✅ Application is responding on private IP"
        else
            echo "❌ Application not responding - may still be starting up"
            echo "📝 Pod logs:"
            kubectl logs -l app=devops-chatbot --tail=20 || echo "No logs available"
        fi
    else
        MINIKUBE_IP=$(minikube ip)
        echo ""
        echo "🌐 Application Access: http://$MINIKUBE_IP:$NODE_PORT"
    fi
    
else
    echo "⚠️ No existing DevOps chatbot deployment found"
    echo "💡 You may need to run the Jenkins pipeline again to redeploy the application"
    echo "💡 Or manually deploy using: kubectl apply -f k8s-deployment.yaml"
fi

echo ""
echo "✅ Minikube recovery completed successfully!"
echo "🎉 Kubernetes cluster is now ready!"
