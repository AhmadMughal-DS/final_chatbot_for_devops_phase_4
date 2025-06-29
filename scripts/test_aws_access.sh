#!/bin/bash

# test_aws_access.sh - Test AWS EC2 application access
echo "🧪 Testing AWS EC2 DevOps Chatbot Access"
echo "========================================"

# Get the current public IP
echo "🔍 Getting public IP..."
PUBLIC_IP=$(curl -s --max-time 5 ifconfig.me 2>/dev/null || curl -s --max-time 5 ipinfo.io/ip 2>/dev/null)
if [ -z "$PUBLIC_IP" ]; then
    PUBLIC_IP="3.14.84.26"  # Fallback to your known IP
fi

# Get NodePort from Kubernetes
NODE_PORT=$(kubectl get service devops-chatbot-service -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "30080")

echo "📍 Testing configuration:"
echo "   Public IP: $PUBLIC_IP"
echo "   NodePort: $NODE_PORT"
echo "   URL: http://$PUBLIC_IP:$NODE_PORT"
echo ""

# Test local connectivity first
echo "🧪 Testing local connectivity..."
PRIVATE_IP=$(hostname -I | awk '{print $1}' 2>/dev/null)
LOCAL_URL="http://$PRIVATE_IP:$NODE_PORT"

echo "🎯 Testing local access: $LOCAL_URL"
if curl -s --max-time 10 "$LOCAL_URL" >/dev/null 2>&1; then
    echo "✅ Local connectivity successful!"
    RESPONSE=$(curl -s --max-time 10 "$LOCAL_URL" | head -100)
    echo "📄 Local response preview: ${RESPONSE:0:200}..."
else
    echo "❌ Local connectivity failed"
    echo "🔍 Checking Kubernetes status..."
    kubectl get pods -l app=devops-chatbot
    kubectl get services devops-chatbot-service
    exit 1
fi

echo ""

# Test public connectivity
echo "🌍 Testing public connectivity..."
PUBLIC_URL="http://$PUBLIC_IP:$NODE_PORT"

echo "🎯 Testing public access: $PUBLIC_URL"
if curl -s --max-time 15 "$PUBLIC_URL" >/dev/null 2>&1; then
    echo "🎉 SUCCESS! Application is accessible from public IP!"
    echo "🌍 Your application URL: $PUBLIC_URL"
    
    RESPONSE=$(curl -s --max-time 10 "$PUBLIC_URL" | head -100)
    echo "📄 Public response preview: ${RESPONSE:0:200}..."
    
    echo ""
    echo "✅ Connectivity test PASSED!"
    echo "🔗 Access your DevOps Chatbot at: $PUBLIC_URL"
    
else
    echo "❌ Public connectivity failed"
    echo ""
    echo "🔍 Troubleshooting steps:"
    echo "1. Check if Security Group allows inbound traffic on port $NODE_PORT"
    echo "2. Verify the application is running: kubectl get pods -l app=devops-chatbot"
    echo "3. Check service configuration: kubectl get services devops-chatbot-service"
    echo ""
    echo "🔧 Security Group configuration needed:"
    echo "   Protocol: TCP"
    echo "   Port: $NODE_PORT"
    echo "   Source: 0.0.0.0/0"
    echo ""
    echo "💡 AWS CLI command to add rule:"
    echo "   aws ec2 authorize-security-group-ingress \\"
    echo "     --group-id <your-security-group-id> \\"
    echo "     --protocol tcp \\"
    echo "     --port $NODE_PORT \\"
    echo "     --cidr 0.0.0.0/0"
    
    exit 1
fi

echo ""
echo "🎯 Quick tests you can run:"
echo "   curl http://$PUBLIC_IP:$NODE_PORT"
echo "   curl http://$PUBLIC_IP:$NODE_PORT/health"
echo ""
echo "📝 Application logs:"
echo "   kubectl logs -l app=devops-chatbot --tail=20"
