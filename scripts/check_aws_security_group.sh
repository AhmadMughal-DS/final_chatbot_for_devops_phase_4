#!/bin/bash

# check_aws_security_group.sh
# Script to check and configure AWS Security Group for Kubernetes NodePort access

set -e

echo "🔍 AWS Security Group Configuration Checker"
echo "============================================"

# Check if we're on AWS EC2
if ! curl -s --max-time 3 http://169.254.169.254/latest/meta-data/instance-id >/dev/null 2>&1; then
    echo "❌ This script must be run on an AWS EC2 instance"
    exit 1
fi

# Get instance metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "No public IP")
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

echo "📋 Instance Information:"
echo "   Instance ID: $INSTANCE_ID"
echo "   Region: $REGION"
echo "   Public IP: $PUBLIC_IP"
echo "   Private IP: $PRIVATE_IP"
echo ""

# Get NodePort from Kubernetes service
NODE_PORT=$(kubectl get service devops-chatbot-service -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "30080")
echo "🚪 Kubernetes NodePort: $NODE_PORT"
echo ""

# Check if AWS CLI is available
if ! command -v aws &> /dev/null; then
    echo "⚠️ AWS CLI not found. Installing..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y awscli
    elif command -v yum &> /dev/null; then
        sudo yum install -y aws-cli
    else
        echo "❌ Cannot install AWS CLI automatically. Please install it manually."
        echo "💡 Manual commands to check security group:"
        echo "   1. Go to AWS Console > EC2 > Security Groups"
        echo "   2. Find security group for instance $INSTANCE_ID"
        echo "   3. Add inbound rule: TCP port $NODE_PORT from 0.0.0.0/0"
        exit 1
    fi
fi

# Check AWS credentials
if ! aws sts get-caller-identity &>/dev/null; then
    echo "⚠️ AWS credentials not configured. Trying instance profile..."
    export AWS_DEFAULT_REGION=$REGION
    if ! aws sts get-caller-identity &>/dev/null; then
        echo "❌ No AWS credentials or instance profile available"
        echo "💡 Please configure AWS credentials or attach an IAM role to this instance"
        echo "💡 Manual Security Group check:"
        echo "   Instance ID: $INSTANCE_ID"
        echo "   Required port: $NODE_PORT (TCP, from 0.0.0.0/0)"
        exit 1
    fi
fi

echo "✅ AWS CLI configured successfully"
echo ""

# Get security groups for this instance
echo "🔍 Checking security groups..."
SECURITY_GROUPS=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --region $REGION \
    --query 'Reservations[0].Instances[0].SecurityGroups[].GroupId' \
    --output text)

if [ -z "$SECURITY_GROUPS" ]; then
    echo "❌ Could not retrieve security groups for instance $INSTANCE_ID"
    exit 1
fi

echo "📋 Security Groups: $SECURITY_GROUPS"
echo ""

# Check each security group for the required rule
RULE_EXISTS=false
for SG in $SECURITY_GROUPS; do
    echo "🔍 Checking Security Group: $SG"
    
    # Check if the rule already exists
    EXISTING_RULE=$(aws ec2 describe-security-groups \
        --group-ids $SG \
        --region $REGION \
        --query "SecurityGroups[0].IpPermissions[?FromPort==\`$NODE_PORT\` && ToPort==\`$NODE_PORT\` && IpProtocol=='tcp']" \
        --output text 2>/dev/null || echo "")
    
    if [ -n "$EXISTING_RULE" ] && [ "$EXISTING_RULE" != "None" ]; then
        echo "✅ Rule for port $NODE_PORT already exists in $SG"
        RULE_EXISTS=true
        
        # Check if it allows access from anywhere
        PUBLIC_ACCESS=$(aws ec2 describe-security-groups \
            --group-ids $SG \
            --region $REGION \
            --query "SecurityGroups[0].IpPermissions[?FromPort==\`$NODE_PORT\` && ToPort==\`$NODE_PORT\` && IpProtocol=='tcp'].IpRanges[?CidrIp=='0.0.0.0/0']" \
            --output text 2>/dev/null || echo "")
        
        if [ -n "$PUBLIC_ACCESS" ] && [ "$PUBLIC_ACCESS" != "None" ]; then
            echo "✅ Public access (0.0.0.0/0) is configured for port $NODE_PORT"
        else
            echo "⚠️ Port $NODE_PORT is open but not for public access (0.0.0.0/0)"
            echo "💡 Current rule allows limited access. Consider adding public access if needed."
        fi
    else
        echo "❌ No rule found for port $NODE_PORT in $SG"
        
        # Ask if user wants to add the rule
        read -p "🤔 Do you want to add a rule to allow access on port $NODE_PORT from anywhere? (y/N): " -n 1 -r
        echo ""
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "➕ Adding security group rule..."
            
            if aws ec2 authorize-security-group-ingress \
                --group-id $SG \
                --protocol tcp \
                --port $NODE_PORT \
                --cidr 0.0.0.0/0 \
                --region $REGION; then
                echo "✅ Successfully added rule to security group $SG"
                RULE_EXISTS=true
            else
                echo "❌ Failed to add rule to security group $SG"
                echo "💡 You may need to add this rule manually in the AWS Console"
            fi
        else
            echo "⏭️ Skipping rule addition for $SG"
        fi
    fi
    echo ""
done

# Test connectivity
echo "🧪 Testing Connectivity:"
echo "========================"

# Test local connectivity
echo "🎯 Testing local connectivity..."
if curl -s --max-time 10 "http://$PRIVATE_IP:$NODE_PORT" >/dev/null 2>&1; then
    echo "✅ Application is accessible locally on private IP"
else
    echo "❌ Application is not accessible locally"
    echo "🔍 Check if Kubernetes service is running:"
    kubectl get services devops-chatbot-service || echo "Service not found"
    kubectl get pods -l app=devops-chatbot || echo "Pods not found"
fi

# Test public connectivity if public IP exists
if [ "$PUBLIC_IP" != "No public IP" ] && [ -n "$PUBLIC_IP" ]; then
    echo "🌍 Testing public connectivity..."
    if curl -s --max-time 10 "http://$PUBLIC_IP:$NODE_PORT" >/dev/null 2>&1; then
        echo "✅ Application is accessible from public IP!"
        echo "🔗 Public URL: http://$PUBLIC_IP:$NODE_PORT"
    else
        echo "❌ Application is not accessible from public IP"
        if [ "$RULE_EXISTS" = true ]; then
            echo "🔍 Security group rule exists but connectivity failed"
            echo "💡 Possible issues:"
            echo "   - Application may not be running"
            echo "   - Network ACLs may be blocking traffic"
            echo "   - Instance may have a host-based firewall"
        else
            echo "🔍 No security group rule found for port $NODE_PORT"
            echo "💡 Add the security group rule and try again"
        fi
    fi
fi

echo ""
echo "📋 Summary:"
echo "==========="
echo "📍 Instance: $INSTANCE_ID ($PRIVATE_IP)"
if [ "$PUBLIC_IP" != "No public IP" ]; then
    echo "🌐 Public URL: http://$PUBLIC_IP:$NODE_PORT"
fi
echo "🏠 Private URL: http://$PRIVATE_IP:$NODE_PORT"
echo "🚪 NodePort: $NODE_PORT"
echo "🔒 Security Groups: $SECURITY_GROUPS"

if [ "$RULE_EXISTS" = true ]; then
    echo "✅ Security group rule configured"
else
    echo "❌ Security group rule missing"
    echo ""
    echo "🛠️ Manual fix:"
    echo "   aws ec2 authorize-security-group-ingress \\"
    echo "     --group-id <security-group-id> \\"
    echo "     --protocol tcp \\"
    echo "     --port $NODE_PORT \\"
    echo "     --cidr 0.0.0.0/0 \\"
    echo "     --region $REGION"
fi

echo ""
echo "✅ Security group check complete!"
