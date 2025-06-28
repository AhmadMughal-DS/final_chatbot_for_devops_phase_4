# Minikube Troubleshooting Commands

## Quick Status Check
```bash
minikube status
kubectl cluster-info
kubectl get nodes
```

## Common Issues and Solutions

### 1. API Server Connection Refused (192.168.49.2:8443)
```bash
# Restart Minikube
minikube stop
minikube start --driver=docker --memory=3900 --cpus=2

# Check if Docker is running
sudo systemctl status docker
sudo systemctl start docker

# Verify Minikube IP
minikube ip
```

### 2. Minikube Won't Start
```bash
# Check available resources
free -h
df -h

# Clean start
minikube delete
minikube start --driver=docker --memory=3900 --cpus=2 --disk-size=20g

# Check logs
minikube logs
```

### 3. kubectl Context Issues
```bash
# Check current context
kubectl config current-context

# Set correct context
kubectl config use-context minikube

# Verify configuration
kubectl config view
```

### 4. Network Issues
```bash
# Check Docker daemon
sudo systemctl status docker

# Check Minikube networking
minikube ssh
# Inside minikube:
ping 8.8.8.8
```

### 5. Your Instance Info
- **Public IP**: 3.14.84.26
- **Private IP**: 172.31.0.45
- **Instance Type**: t2.large (2 vCPUs, 8GB RAM)

## Recovery Script
```bash
chmod +x scripts/fix_minikube.sh
./scripts/fix_minikube.sh
```

## Manual Recovery Steps
```bash
# Step 1: Stop everything
minikube stop
sudo systemctl restart docker

# Step 2: Start fresh
minikube delete  # Only if necessary
minikube start --driver=docker --memory=3900 --cpus=2

# Step 3: Verify
minikube status
kubectl cluster-info
kubectl get nodes

# Step 4: Enable addons
minikube addons enable metrics-server
```

## Access Your Application
```bash
# Get Minikube IP
minikube ip

# Get NodePort
kubectl get service devops-chatbot-nodeport

# Access URL
http://<minikube-ip>:30080
```
