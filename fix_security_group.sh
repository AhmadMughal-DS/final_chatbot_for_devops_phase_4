#!/bin/bash

# AWS Security Group Port 30080 Checker and Fixer Script
echo "🔒 AWS Security Group Configuration Helper"
echo "=========================================="

PORT="30080"
echo "📍 Checking for port $PORT access rules..."

# Check if AWS CLI is available
if ! command -v aws >/dev/null 2>&1; then
    echo "❌ AWS CLI not found. Please install AWS CLI first."
    echo "💡 Install with: sudo apt install awscli"
    exit 1
fi

# Get instance metadata
echo "🔍 Getting instance information..."
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null || echo "unknown")
echo "Instance ID: $INSTANCE_ID"

if [ "$INSTANCE_ID" != "unknown" ]; then
    # Get security groups for this instance
    echo "🔍 Getting security groups for this instance..."
    SECURITY_GROUPS=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].SecurityGroups[*].GroupId' --output text 2>/dev/null || echo "")
    
    if [ -n "$SECURITY_GROUPS" ]; then
        echo "📋 Security Groups: $SECURITY_GROUPS"
        
        for SG in $SECURITY_GROUPS; do
            echo ""
            echo "🔍 Checking Security Group: $SG"
            
            # Check if port 30080 is already open
            RULE_EXISTS=$(aws ec2 describe-security-groups --group-ids $SG --query "SecurityGroups[0].IpPermissions[?FromPort==\`$PORT\` && ToPort==\`$PORT\`]" --output text 2>/dev/null)
            
            if [ -n "$RULE_EXISTS" ] && [ "$RULE_EXISTS" != "None" ]; then
                echo "✅ Port $PORT is already open in security group $SG"
                aws ec2 describe-security-groups --group-ids $SG --query "SecurityGroups[0].IpPermissions[?FromPort==\`$PORT\` && ToPort==\`$PORT\`]" --output table
            else
                echo "❌ Port $PORT is NOT open in security group $SG"
                echo ""
                echo "🛠️ To fix this, run the following command:"
                echo "aws ec2 authorize-security-group-ingress \\"
                echo "    --group-id $SG \\"
                echo "    --protocol tcp \\"
                echo "    --port $PORT \\"
                echo "    --cidr 0.0.0.0/0"
                echo ""
                
                # Ask if user wants to add the rule automatically
                read -p "🤔 Do you want to add this rule automatically? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    echo "🔧 Adding security group rule..."
                    if aws ec2 authorize-security-group-ingress --group-id $SG --protocol tcp --port $PORT --cidr 0.0.0.0/0; then
                        echo "✅ Successfully added security group rule!"
                        echo "🎉 Port $PORT is now open for public access"
                    else
                        echo "❌ Failed to add security group rule"
                        echo "💡 You may need to add it manually in AWS Console"
                    fi
                else
                    echo "⏭️ Skipping automatic rule addition"
                fi
            fi
        done
    else
        echo "❌ Could not retrieve security groups"
    fi
else
    echo "❌ Could not retrieve instance metadata"
    echo "💡 You may need to manually check your security groups"
fi

echo ""
echo "🌐 After fixing security groups, test access with:"
echo "   curl http://3.14.84.26:$PORT"
echo "   curl http://172.31.0.45:$PORT"
echo ""
echo "🔗 Your application should be available at:"
echo "   📡 Public: http://3.14.84.26:$PORT"
echo "   🏠 Private: http://172.31.0.45:$PORT"
