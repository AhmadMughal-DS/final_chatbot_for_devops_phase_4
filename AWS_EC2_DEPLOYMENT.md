# AWS EC2 Deployment Guide

This guide provides instructions for deploying the DevOps Chatbot on AWS EC2 with proper security group configuration and external access.

## 🌩️ AWS EC2 Deployment Overview

The updated Jenkins pipeline now automatically detects AWS EC2 environments and provides the correct access URLs for both public and private access.

## 📋 Prerequisites

1. **AWS EC2 Instance** with:
   - Ubuntu/Amazon Linux
   - Docker installed
   - Kubernetes (Minikube or managed cluster)
   - Jenkins installed and running
   - Public IP assigned (for external access)

2. **Security Group Configuration**:
   - SSH access (port 22) from your IP
   - Jenkins access (port 8080) from your IP  
   - **Kubernetes NodePort access (port 30080 or custom)** from 0.0.0.0/0

## 🚀 Deployment Steps

### 1. Run Jenkins Pipeline

The Jenkins pipeline will automatically:
- Detect AWS EC2 environment
- Build and deploy the application
- Configure Kubernetes services
- Display correct access URLs
- Provide security group configuration guidance

### 2. Check Security Group Configuration

After deployment, run the security group check script:

```bash
cd /path/to/project
./scripts/check_aws_security_group.sh
```

Or manually check/configure:

```bash
# Get your instance's security group
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)

# Get security groups
aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --region $REGION \
  --query 'Reservations[0].Instances[0].SecurityGroups'

# Add NodePort rule (replace <sg-id> and <node-port>)
aws ec2 authorize-security-group-ingress \
  --group-id <sg-id> \
  --protocol tcp \
  --port <node-port> \
  --cidr 0.0.0.0/0 \
  --region $REGION
```

### 3. Verify Deployment

The pipeline will automatically test connectivity and display:

```
🌩️ AWS EC2 Environment Detected!
======================================
🌐 Public IP: 3.14.84.26
🏠 Private IP: 172.31.x.x
🚪 NodePort: 30080

🔗 Access URLs:
   📡 External (Public): http://3.14.84.26:30080
   🌍 Internet Access: http://3.14.84.26:30080
   🏠 Internal (Private): http://172.31.x.x:30080
   🔒 VPC Access: http://172.31.x.x:30080
```

## 🔧 Manual Verification Commands

```bash
# Check Kubernetes deployment
kubectl get pods -l app=devops-chatbot
kubectl get services devops-chatbot-service
kubectl get hpa devops-chatbot-hpa

# Get NodePort
NODE_PORT=$(kubectl get service devops-chatbot-service -o jsonpath='{.spec.ports[0].nodePort}')
echo "NodePort: $NODE_PORT"

# Test local connectivity
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
curl -s "http://$PRIVATE_IP:$NODE_PORT" || echo "Local test failed"

# Test public connectivity (if public IP exists)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
curl -s "http://$PUBLIC_IP:$NODE_PORT" || echo "Public test failed"
```

## 🔐 Security Group Requirements

### Required Inbound Rules:

| Type | Protocol | Port Range | Source | Description |
|------|----------|------------|---------|-------------|
| SSH | TCP | 22 | Your IP | SSH access |
| Custom TCP | TCP | 8080 | Your IP | Jenkins web interface |
| Custom TCP | TCP | 30080* | 0.0.0.0/0 | Kubernetes NodePort |

*The actual NodePort may vary (30000-32767 range)

### AWS Console Steps:

1. Go to **EC2 Dashboard** → **Security Groups**
2. Find security group associated with your instance
3. Click **Inbound rules** → **Edit inbound rules**
4. Add rule:
   - Type: Custom TCP
   - Port range: [NodePort from kubectl command]
   - Source: 0.0.0.0/0 (for public access)
   - Description: Kubernetes NodePort for DevOps Chatbot

## 🧪 Testing Access

### From Local Machine:
```bash
# Replace with your EC2 public IP and NodePort
curl http://3.14.84.26:30080
```

### From Browser:
Open: `http://your-public-ip:nodeport`

### Expected Response:
```json
{"message": "DevOps Chatbot API is running", "status": "healthy"}
```

## 🛠️ Troubleshooting

### Application Not Accessible Externally

1. **Check Security Group**:
   ```bash
   ./scripts/check_aws_security_group.sh
   ```

2. **Verify Kubernetes Service**:
   ```bash
   kubectl get services devops-chatbot-service
   kubectl describe service devops-chatbot-service
   ```

3. **Check Pod Status**:
   ```bash
   kubectl get pods -l app=devops-chatbot
   kubectl logs -l app=devops-chatbot --tail=50
   ```

4. **Test Local Connectivity**:
   ```bash
   PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
   NODE_PORT=$(kubectl get service devops-chatbot-service -o jsonpath='{.spec.ports[0].nodePort}')
   curl "http://$PRIVATE_IP:$NODE_PORT"
   ```

### Common Issues:

1. **Security Group Not Updated**: Add NodePort rule as described above
2. **Application Not Running**: Check pod status and logs
3. **Wrong Port**: Verify NodePort from kubectl command
4. **Network ACLs**: Ensure VPC network ACLs allow traffic
5. **Instance Firewall**: Check if instance has additional firewall rules

## 📈 Monitoring and Management

### Check Deployment Status:
```bash
./scripts/check_deployment_status.sh
```

### Scale Application:
```bash
kubectl scale deployment devops-chatbot-deployment --replicas=3
```

### View Auto-scaling:
```bash
kubectl get hpa devops-chatbot-hpa
kubectl describe hpa devops-chatbot-hpa
```

### Stop Application:
```bash
./scripts/cleanup_k8s_manual.sh
```

## 🔄 Continuous Deployment

The Jenkins pipeline is configured for persistent deployment:
- Application stays running after pipeline completion
- Auto-scaling enabled via HPA
- Health checks and automatic restarts
- No automatic cleanup

To trigger new deployments:
- Push code changes to trigger webhook
- Or manually run Jenkins pipeline
- Existing deployment will be updated with zero-downtime

## 📞 Support

If you encounter issues:
1. Check Jenkins build logs
2. Review Kubernetes events: `kubectl get events --sort-by=.metadata.creationTimestamp`
3. Check application logs: `kubectl logs -l app=devops-chatbot`
4. Verify security group configuration with provided script
5. Ensure all prerequisites are met

The deployment should now be accessible from your AWS EC2 public IP on the configured NodePort!
