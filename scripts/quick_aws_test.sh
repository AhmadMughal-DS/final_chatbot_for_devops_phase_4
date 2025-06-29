#!/bin/bash

# quick_aws_test.sh
# Quick test script for AWS EC2 DevOps Chatbot deployment

echo "🧪 Quick AWS EC2 DevOps Chatbot Test"
echo "===================================="

# Check if we're on AWS EC2
if curl -s --max-time 3 http://169.254.169.254/latest/meta-data/instance-id >/dev/null 2>&1; then
    PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "")
    PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    
    echo "✅ AWS EC2 detected"
    echo "📍 Instance ID: $INSTANCE_ID"
    echo "🌐 Public IP: ${PUBLIC_IP:-'Not available'}"
    echo "🏠 Private IP: $PRIVATE_IP"
else
    echo "❌ Not running on AWS EC2"
    exit 1
fi

# Get NodePort
NODE_PORT=$(kubectl get service devops-chatbot-service -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
if [ -z "$NODE_PORT" ]; then
    echo "❌ DevOps Chatbot service not found"
    echo "🔍 Available services:"
    kubectl get services
    exit 1
fi

echo "🚪 NodePort: $NODE_PORT"
echo ""

# Test internal connectivity
echo "🧪 Testing internal connectivity..."
INTERNAL_URL="http://$PRIVATE_IP:$NODE_PORT"
echo "🎯 Testing: $INTERNAL_URL"

if curl -s --max-time 10 "$INTERNAL_URL" >/dev/null 2>&1; then
    echo "✅ Internal connectivity successful"
    RESPONSE=$(curl -s --max-time 10 "$INTERNAL_URL")
    echo "📄 Response: $RESPONSE"
else
    echo "❌ Internal connectivity failed"
    echo "🔍 Checking pod status..."
    kubectl get pods -l app=devops-chatbot
    kubectl get services devops-chatbot-service
    exit 1
fi

# Test external connectivity if public IP exists
if [ -n "$PUBLIC_IP" ]; then
    echo ""
    echo "🧪 Testing external connectivity..."
    EXTERNAL_URL="http://$PUBLIC_IP:$NODE_PORT"
    echo "🎯 Testing: $EXTERNAL_URL"
    
    if curl -s --max-time 10 "$EXTERNAL_URL" >/dev/null 2>&1; then
        echo "✅ External connectivity successful!"
        echo "🌍 Your application is accessible at: $EXTERNAL_URL"
        RESPONSE=$(curl -s --max-time 10 "$EXTERNAL_URL")
        echo "📄 Response: $RESPONSE"
    else
        echo "❌ External connectivity failed"
        echo "🔍 This usually means the security group is not configured correctly"
        echo ""
        echo "🛠️ To fix this issue:"
        echo "   1. Go to AWS Console > EC2 > Security Groups"
        echo "   2. Find the security group for instance $INSTANCE_ID"
        echo "   3. Add inbound rule:"
        echo "      - Type: Custom TCP"
        echo "      - Port: $NODE_PORT"
        echo "      - Source: 0.0.0.0/0"
        echo ""
        echo "🔧 Or use AWS CLI:"
        echo "   aws ec2 authorize-security-group-ingress \\"
        echo "     --group-id <your-security-group-id> \\"
        echo "     --protocol tcp \\"
        echo "     --port $NODE_PORT \\"
        echo "     --cidr 0.0.0.0/0"
    fi
else
    echo "⚠️ No public IP available for external testing"
fi

echo ""
echo "📋 Summary:"
echo "==========="
if [ -n "$PUBLIC_IP" ]; then
    echo "🌍 External URL: http://$PUBLIC_IP:$NODE_PORT"
fi
echo "🏠 Internal URL: http://$PRIVATE_IP:$NODE_PORT"
echo "🚪 NodePort: $NODE_PORT"
echo "📍 Instance: $INSTANCE_ID"

echo ""
echo "✅ Test completed!"
