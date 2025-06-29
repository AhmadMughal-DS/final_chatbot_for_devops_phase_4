# AWS EC2 Public Access Troubleshooting Guide

## Issue: Application Not Accessible from Public IP

Based on your Jenkins output, the application is running successfully but cannot be accessed from the public IP. Here's how to fix it:

## ✅ What's Working
- Jenkins pipeline completed successfully
- Kubernetes pods are running (STATUS: Running)
- Application is responding to health checks
- NodePort is configured (30080)
- AWS EC2 instance is detected

## ❌ The Problem
The AWS metadata service is returning empty values for public/private IPs, which means:
```
🌍 Public IP: (empty)
🏠 Private IP: (empty) 
🚀 Access your application at: http://:30080
```

## 🔧 Immediate Fix Steps

### 1. Get Your Actual Public IP
Run this on your EC2 instance:
```bash
# Method 1: External service
curl ifconfig.me

# Method 2: AWS metadata (if working)
curl http://169.254.169.254/latest/meta-data/public-ipv4

# Method 3: AWS CLI
aws ec2 describe-instances --instance-ids $(curl -s http://169.254.169.254/latest/meta-data/instance-id) --query 'Reservations[0].Instances[0].PublicIpAddress'
```

### 2. Verify NodePort
```bash
kubectl get service devops-chatbot-service -o jsonpath='{.spec.ports[0].nodePort}'
# Should output: 30080
```

### 3. Test Local Connectivity First
```bash
# Get private IP
PRIVATE_IP=$(hostname -I | awk '{print $1}')
echo "Private IP: $PRIVATE_IP"

# Test local access
curl http://$PRIVATE_IP:30080
```

### 4. Configure Security Group
Your security group MUST allow inbound traffic on port 30080:

**AWS Console Method:**
1. Go to EC2 Dashboard → Security Groups
2. Find your instance's security group
3. Edit Inbound Rules → Add Rule:
   - Type: Custom TCP
   - Port Range: 30080
   - Source: 0.0.0.0/0
   - Description: Kubernetes NodePort for DevOps Chatbot

**AWS CLI Method:**
```bash
# Get your security group ID
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
SG_ID=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' --output text)

# Add the rule
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 30080 \
  --cidr 0.0.0.0/0
```

### 5. Test Public Access
After configuring the security group:
```bash
# Replace with your actual public IP
PUBLIC_IP="3.14.84.26"  # Your IP from the original request

# Test access
curl http://$PUBLIC_IP:30080

# Test health endpoint
curl http://$PUBLIC_IP:30080/health
```

## 🧪 Quick Test Script
Run the automated test script:
```bash
cd /path/to/your/project
./scripts/test_aws_access.sh
```

## 📝 Expected Success Output
When working correctly, you should see:
```bash
✅ Local connectivity successful!
🎉 SUCCESS! Application is accessible from public IP!
🌍 Your application URL: http://3.14.84.26:30080
```

## 🔍 Verification Commands

### Check Kubernetes Status
```bash
kubectl get pods -l app=devops-chatbot
kubectl get services devops-chatbot-service
kubectl logs -l app=devops-chatbot --tail=20
```

### Check Security Group
```bash
# List current rules
aws ec2 describe-security-groups --group-ids $SG_ID

# Check for port 30080
aws ec2 describe-security-groups --group-ids $SG_ID \
  --query 'SecurityGroups[0].IpPermissions[?FromPort==`30080`]'
```

## 🚨 Common Issues

### Issue 1: Security Group Not Updated
**Symptom:** Local access works, public access fails
**Solution:** Add security group rule for port 30080

### Issue 2: Wrong Public IP
**Symptom:** Using empty or wrong IP
**Solution:** Get actual public IP using the methods above

### Issue 3: Application Not Running
**Symptom:** Both local and public access fail
**Solution:** Check pod status and logs

### Issue 4: Network ACLs
**Symptom:** Security group is correct but still can't access
**Solution:** Check VPC Network ACLs allow traffic on port 30080

## 📞 Next Steps

1. **First**: Configure security group for port 30080
2. **Second**: Get your actual public IP (probably 3.14.84.26)
3. **Third**: Test access: `curl http://3.14.84.26:30080`
4. **Fourth**: If still failing, run the test script for detailed diagnostics

## 💡 Pro Tips
- Use `./scripts/test_aws_access.sh` for automated testing
- The application is running - this is just a network configuration issue
- Jenkins pipeline improvements will prevent this in future runs
- Always test local connectivity first before public access

Your application should be accessible at: **http://3.14.84.26:30080** once the security group is configured!
