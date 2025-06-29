# System Restart Recovery Guide

This document provides comprehensive guidance for recovering your DevOps Chatbot application after a system restart, when Minikube is not responding.

## 🚨 Quick Diagnosis

When you see this error:
```
error: error loading config file "/home/ec2-user/.kube/config": open /home/ec2-user/.kube/config: no such file or directory
Unable to connect to the server: dial tcp 192.168.49.2:8443: i/o timeout
```

This means Minikube has stopped working after a system restart and needs to be recovered.

## 🛠️ Recovery Scripts Available

### 1. **Full System Recovery** (Recommended)
**Script:** `scripts/system_restart_recovery.sh`
**Use when:** Complete system restart, Minikube not responding, application needs redeployment
**What it does:**
- ✅ Checks all prerequisites (Docker, kubectl, minikube)
- ✅ Stops and cleans up hanging processes
- ✅ Restarts Minikube with optimal settings
- ✅ Rebuilds Docker image if needed
- ✅ Redeploys the entire application
- ✅ Shows access URLs and tests connectivity

```bash
# Run from project root directory
cd /path/to/final_chatbot_for_devops_phase_4
chmod +x scripts/system_restart_recovery.sh
./scripts/system_restart_recovery.sh
```

### 2. **Minikube Quick Recovery**
**Script:** `scripts/restart_minikube.sh`
**Use when:** Only Minikube needs restarting, application may still be deployed
**What it does:**
- ✅ Diagnoses current Minikube status
- ✅ Starts Docker if needed
- ✅ Restarts Minikube
- ✅ Checks existing application deployment
- ✅ Shows access information if app is found

```bash
# Run from anywhere
chmod +x scripts/restart_minikube.sh
./scripts/restart_minikube.sh
```

## 🎯 Step-by-Step Manual Recovery

If scripts don't work, follow these manual steps:

### Step 1: Check System Prerequisites
```bash
# Check if Docker is running
sudo systemctl status docker
sudo systemctl start docker  # if not running

# Check if tools are installed
which docker kubectl minikube
```

### Step 2: Clean Up and Restart Minikube
```bash
# Stop existing processes
sudo pkill -f minikube
sudo pkill -f kubectl

# Stop and restart Minikube
minikube stop
minikube start --driver=docker --memory=2048 --cpus=2
```

### Step 3: Wait for Cluster Ready
```bash
# Wait for API server
kubectl cluster-info --request-timeout=10s

# Check cluster nodes
kubectl get nodes
```

### Step 4: Check Application Status
```bash
# Check if application is deployed
kubectl get pods -l app=devops-chatbot
kubectl get services devops-chatbot-service
```

### Step 5: Redeploy if Needed
```bash
# If application is not running, redeploy
kubectl apply -f k8s-pvc.yaml
kubectl apply -f k8s-deployment.yaml
kubectl apply -f k8s-service.yaml
kubectl apply -f k8s-hpa.yaml
```

## 🌐 Getting Access URLs

After recovery, get your access URLs:

```bash
# Get NodePort
NODE_PORT=$(kubectl get service devops-chatbot-service -o jsonpath='{.spec.ports[0].nodePort}')

# For AWS EC2
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

echo "Public URL: http://$PUBLIC_IP:$NODE_PORT"
echo "Private URL: http://$PRIVATE_IP:$NODE_PORT"
```

## 🔥 AWS Security Group Check

**Important:** After recovery, ensure AWS Security Group allows your NodePort:

```bash
# Run security group checker
chmod +x fix_security_group.sh
./fix_security_group.sh
```

Or manually:
1. Go to AWS EC2 Console → Security Groups
2. Find your instance's security group
3. Add inbound rule: `Custom TCP`, Port `30080`, Source `0.0.0.0/0`

## 🧪 Testing Application

Test if application is working:

```bash
# Test locally (on EC2 instance)
curl -v http://localhost:30080

# Test connectivity script
chmod +x check_access.sh
./check_access.sh
```

## 📝 Common Issues and Solutions

### Issue 1: Docker not starting
```bash
sudo systemctl status docker
sudo systemctl start docker
sudo systemctl enable docker
```

### Issue 2: Minikube start fails
```bash
# Try with minimal resources
minikube delete
minikube start --driver=docker --memory=1536 --cpus=1
```

### Issue 3: Application not accessible externally
- Check AWS Security Group (port 30080)
- Verify NodePort service is running
- Test from within EC2 instance first

### Issue 4: Pods stuck in Pending/ImagePullBackOff
```bash
# Check pod status
kubectl describe pods -l app=devops-chatbot

# Rebuild Docker image
eval $(minikube docker-env)
docker build -t devops-chatbot:latest .
```

## 💡 Prevention Tips

To avoid issues in the future:

1. **Enable Docker auto-start:**
   ```bash
   sudo systemctl enable docker
   ```

2. **Set up Minikube auto-start** (optional):
   Add to crontab: `@reboot /usr/local/bin/minikube start`

3. **Keep scripts executable:**
   ```bash
   chmod +x scripts/*.sh
   ```

## 🆘 Emergency Commands

If everything fails:
```bash
# Nuclear option - complete reset
minikube delete
docker system prune -a
sudo systemctl restart docker

# Then run full recovery script
./scripts/system_restart_recovery.sh
```

## 📞 Getting Help

If you're still having issues:

1. Check the logs:
   ```bash
   minikube logs
   kubectl logs -l app=devops-chatbot
   ```

2. Check system resources:
   ```bash
   free -h
   df -h
   docker info
   ```

3. Run diagnostics:
   ```bash
   kubectl describe pods -l app=devops-chatbot
   kubectl get events --sort-by=.metadata.creationTimestamp
   ```

Remember: The **Full System Recovery** script (`scripts/system_restart_recovery.sh`) is your best bet for a complete recovery after a system restart!
