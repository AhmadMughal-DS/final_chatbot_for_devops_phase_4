# DevOps Chatbot Access Troubleshooting Guide

## Issue: Application Not Accessible via Web Browser

Your Jenkins pipeline deployed successfully, but you cannot access the application via Chrome browser. This is a common AWS security group configuration issue.

## Quick Fix Summary

**Your Application URLs:**
- 📡 Public Access: http://3.14.84.26:30080
- 🏠 Private Access: http://172.31.0.45:30080

**Problem:** AWS Security Group is not allowing inbound traffic on port 30080.

## Step-by-Step Solution

### Option 1: Fix via AWS Console (Recommended for beginners)

1. **Login to AWS Console**
   - Go to https://console.aws.amazon.com
   - Navigate to EC2 → Instances

2. **Find Your Instance**
   - Look for instance with IP 3.14.84.26
   - Click on the instance

3. **Check Security Groups**
   - In the instance details, click on "Security" tab
   - Click on the Security Group name

4. **Add Inbound Rule**
   - Click "Edit inbound rules"
   - Click "Add rule"
   - Set:
     - Type: Custom TCP
     - Port Range: 30080
     - Source: 0.0.0.0/0 (for public access)
     - Description: DevOps Chatbot Access
   - Click "Save rules"

### Option 2: Fix via AWS CLI (Advanced)

```bash
# Run this on your EC2 instance
./fix_security_group.sh
```

Or manually:
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

### Option 3: Test Access

After fixing the security group, test access:

```bash
# Run this to test connectivity
./check_access.sh
```

Or manually:
```bash
curl http://3.14.84.26:30080
curl http://172.31.0.45:30080
```

## Expected Result

After fixing the security group, you should be able to access:
- **Main Application**: http://3.14.84.26:30080
- **Health Check**: http://3.14.84.26:30080/health

## Jenkins Pipeline Improvements

The updated Jenkins pipeline now:
1. ✅ Uses hardcoded IP fallbacks (3.14.84.26 and 172.31.0.45)
2. ✅ Increased timeout values for metadata service calls
3. ✅ Multiple fallback methods for IP detection
4. ✅ Clear error messages and URLs in output

## Verification Commands

```bash
# Check if application is running
kubectl get pods -l app=devops-chatbot

# Check service status
kubectl get svc devops-chatbot-service

# Check application logs
kubectl logs -l app=devops-chatbot

# Test from within EC2
curl http://localhost:30080
curl http://172.31.0.45:30080
```

## Security Group Rule Details

Required rule for public access:
- **Type**: Custom TCP
- **Protocol**: TCP
- **Port Range**: 30080
- **Source**: 0.0.0.0/0
- **Description**: DevOps Chatbot Public Access

For internal-only access, use your VPC CIDR instead of 0.0.0.0/0.

## Troubleshooting

If still not working after security group fix:

1. **Check application status**:
   ```bash
   kubectl get pods -l app=devops-chatbot
   kubectl logs -l app=devops-chatbot
   ```

2. **Verify NodePort service**:
   ```bash
   kubectl get svc devops-chatbot-service
   ```

3. **Test internal connectivity**:
   ```bash
   curl http://localhost:30080
   ```

4. **Check if port is listening**:
   ```bash
   netstat -tlnp | grep 30080
   ```

## Next Steps

1. Run the updated Jenkins pipeline (it will use the correct IPs)
2. Fix the security group using Option 1 or 2 above
3. Access your application at http://3.14.84.26:30080
4. Test the chatbot functionality

The application should be fully functional with DevOps Q&A capabilities once the security group is properly configured.
