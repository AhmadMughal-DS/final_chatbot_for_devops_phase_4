#!/bin/bash

echo "🔧 Fixing DNS and Network Issues for Docker Build..."

# Check if running inside Minikube
if [ -n "$MINIKUBE_ACTIVE_DOCKERD" ]; then
    echo "✅ Running inside Minikube environment"
else
    echo "⚠️ Not in Minikube environment, setting up..."
    eval $(minikube docker-env)
fi

# Test network connectivity
echo "🌐 Testing network connectivity..."
ping -c 2 8.8.8.8 > /dev/null && echo "✅ Internet connectivity OK" || echo "❌ Internet connectivity issue"
nslookup pypi.org > /dev/null && echo "✅ DNS resolution OK" || echo "❌ DNS resolution issue"

# Build with DNS configuration
echo "🔨 Building Docker image with DNS fixes..."

# Primary build with DNS
docker build \
    --dns=8.8.8.8 \
    --dns=8.8.4.4 \
    --build-arg http_proxy= \
    --build-arg https_proxy= \
    -t devops-chatbot:latest . && echo "✅ Primary build successful" && exit 0

echo "⚠️ Primary build failed, trying fallback methods..."

# Fallback 1: Use simplified Dockerfile
if [ -f "Dockerfile.fallback" ]; then
    echo "🔄 Trying fallback Dockerfile..."
    docker build \
        --dns=8.8.8.8 \
        --dns=8.8.4.4 \
        -f Dockerfile.fallback \
        -t devops-chatbot:latest . && echo "✅ Fallback build successful" && exit 0
fi

# Fallback 2: Use simplified requirements
if [ -f "requirements-simple.txt" ]; then
    echo "🔄 Trying with simplified requirements..."
    cp requirements-simple.txt requirements.txt
    docker build \
        --dns=8.8.8.8 \
        --dns=8.8.4.4 \
        --no-cache \
        -t devops-chatbot:latest . && echo "✅ Simplified build successful" && exit 0
fi

# Fallback 3: Use host network
echo "🔄 Trying with host network..."
docker build \
    --network=host \
    -t devops-chatbot:latest . && echo "✅ Host network build successful" && exit 0

echo "❌ All build methods failed"
exit 1
