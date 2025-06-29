#!/bin/bash

# Check application access script
echo "🔍 DevOps Chatbot Access Checker"
echo "================================"

# Your IPs
PUBLIC_IP="3.14.84.26"
PRIVATE_IP="172.31.0.45"
NODE_PORT="30080"

echo "📍 Checking application at:"
echo "   Public IP: $PUBLIC_IP"
echo "   Private IP: $PRIVATE_IP"
echo "   Port: $NODE_PORT"
echo ""

# Test public IP access
echo "🌐 Testing public IP access..."
if curl -s --max-time 10 "http://$PUBLIC_IP:$NODE_PORT" >/dev/null 2>&1; then
    echo "✅ Public IP access: WORKING"
    echo "🔗 Access URL: http://$PUBLIC_IP:$NODE_PORT"
else
    echo "❌ Public IP access: FAILED"
    echo "💡 This might be due to:"
    echo "   - Security Group not allowing port $NODE_PORT"
    echo "   - Application not running"
    echo "   - Wrong IP address"
fi

echo ""

# Test private IP access (if running from within AWS)
echo "🏠 Testing private IP access..."
if curl -s --max-time 10 "http://$PRIVATE_IP:$NODE_PORT" >/dev/null 2>&1; then
    echo "✅ Private IP access: WORKING"
    echo "🔗 Internal URL: http://$PRIVATE_IP:$NODE_PORT"
else
    echo "❌ Private IP access: FAILED"
fi

echo ""

# Check if kubectl is available and get pod status
if command -v kubectl >/dev/null 2>&1; then
    echo "📊 Kubernetes Status:"
    echo "-------------------"
    kubectl get pods -l app=devops-chatbot 2>/dev/null || echo "❌ Cannot get pod status"
    kubectl get svc devops-chatbot-service 2>/dev/null || echo "❌ Cannot get service status"
else
    echo "⚠️ kubectl not available - cannot check Kubernetes status"
fi

echo ""
echo "🛠️ Troubleshooting Tips:"
echo "------------------------"
echo "1. Ensure AWS Security Group allows inbound TCP traffic on port $NODE_PORT"
echo "2. Check if the application pod is running: kubectl get pods -l app=devops-chatbot"
echo "3. Verify the service: kubectl get svc devops-chatbot-service"
echo "4. Check application logs: kubectl logs -l app=devops-chatbot"
echo ""
echo "📋 AWS Security Group Rule needed:"
echo "   Type: Custom TCP"
echo "   Port Range: $NODE_PORT"
echo "   Source: 0.0.0.0/0 (for public access)"
echo "   Protocol: TCP"
