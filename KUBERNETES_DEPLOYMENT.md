# Kubernetes Deployment Guide for DevOps Chatbot

## Prerequisites
1. Minikube installed and running on AWS EC2
2. kubectl configured to work with your Minikube cluster
3. Docker image built locally in Minikube

## 🚨 Important: API Server Connectivity Issues
If you encounter the error "The connection to the server localhost:8443 was refused", this indicates Minikube API server connectivity issues. This guide includes comprehensive recovery mechanisms.

### Quick Recovery Options:
1. **Automated**: The Jenkins pipeline includes enhanced recovery mechanisms
2. **Manual**: Use `scripts/manual_recovery.sh` for guided recovery
3. **Advanced**: Use `scripts/fix_minikube_advanced.sh` for comprehensive reset
4. **Detailed Guide**: See `API_SERVER_TROUBLESHOOTING.md` for complete troubleshooting

## Files Created

1. **k8s-pvc.yaml** - PersistentVolumeClaims for data and frontend storage
2. **k8s-deployment.yaml** - Deployment configuration with 2 replicas
3. **k8s-service.yaml** - Services for exposing the application
4. **k8s-hpa.yaml** - Horizontal Pod Autoscaler for automatic scaling

## Deployment Steps

### 1. Build Docker Image in Minikube
```bash
# Set Docker environment to use Minikube's Docker daemon
eval $(minikube docker-env)

# Build the image
docker build -t devops-chatbot:latest .

# Verify image is built
docker images | grep devops-chatbot
```

### 2. Apply Kubernetes Manifests
```bash
# Apply PersistentVolumeClaims first
kubectl apply -f k8s-pvc.yaml

# Verify PVCs are created
kubectl get pvc

# Apply Deployment
kubectl apply -f k8s-deployment.yaml

# Apply Services
kubectl apply -f k8s-service.yaml

# Apply HPA (Horizontal Pod Autoscaler)
kubectl apply -f k8s-hpa.yaml
```

### 3. Enable Metrics Server (Required for HPA)
```bash
# Enable metrics-server addon in Minikube
minikube addons enable metrics-server

# Verify metrics server is running
kubectl get pods -n kube-system | grep metrics-server

# Wait a few minutes, then check if metrics are available
kubectl top nodes
kubectl top pods
```

### 3. Check Deployment Status
```bash
# Check pods
kubectl get pods -l app=devops-chatbot

# Check services
kubectl get services

# Check deployments
kubectl get deployments

# Check HPA status
kubectl get hpa

# Get detailed pod information
kubectl describe pods -l app=devops-chatbot

# Check HPA details and current metrics
kubectl describe hpa devops-chatbot-hpa
```

### 4. Access the Application

#### Option 1: NodePort Service
```bash
# Get Minikube IP
minikube ip

# Access application at: http://<minikube-ip>:30080
```

#### Option 2: LoadBalancer Service (in Minikube)
```bash
# Get LoadBalancer URL
minikube service devops-chatbot-loadbalancer --url
```

#### Option 3: Port Forward (for testing)
```bash
kubectl port-forward service/devops-chatbot-service 8000:8000
# Access at: http://localhost:8000
```

### 5. Useful Commands

#### View Logs
```bash
kubectl logs -l app=devops-chatbot
kubectl logs -f deployment/devops-chatbot-deployment
```

#### Scale Application
```bash
kubectl scale deployment devops-chatbot-deployment --replicas=3
```

#### Monitor HPA Scaling
```bash
# Watch HPA status in real-time
kubectl get hpa -w

# Generate load to test autoscaling
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh
# Inside the pod, run:
while true; do wget -q -O- http://devops-chatbot-service:8000/; done

# Check current resource usage
kubectl top pods -l app=devops-chatbot
```

#### Update Application
```bash
# After building new image
kubectl rollout restart deployment/devops-chatbot-deployment
```

#### Clean Up
```bash
kubectl delete -f k8s-hpa.yaml
kubectl delete -f k8s-service.yaml
kubectl delete -f k8s-deployment.yaml
kubectl delete -f k8s-pvc.yaml
```

## Configuration Details

### Resources (Optimized for AWS t2.large)
- **Memory**: 512Mi request, 1Gi limit per pod
- **CPU**: 500m request, 800m limit per pod
- **Storage**: 1Gi for app data, 500Mi for frontend

### HPA Configuration (Optimized for t2.large)
- **Min Replicas**: 1 pod minimum
- **Max Replicas**: 6 pods maximum (considering t2.large capacity)
- **CPU Target**: 60% utilization (lower threshold for better responsiveness)
- **Memory Target**: 70% utilization
- **Scale Down**: Maximum 10% reduction per minute
- **Scale Up**: Maximum 50% increase per 30 seconds or 2 pods per minute

### Environment Variables
- `MONGODB_URI`: Your MongoDB connection string
- `DEBUG`: Set to "1" for debug mode

### Health Checks
- **Liveness Probe**: HTTP GET on port 8000 every 10 seconds
- **Readiness Probe**: HTTP GET on port 8000 every 5 seconds

## Troubleshooting

### If pods are not starting:
```bash
kubectl describe pods -l app=devops-chatbot
kubectl logs <pod-name>
```

### If service is not accessible:
```bash
kubectl get endpoints
minikube service list
```

### If image pull fails:
Make sure you're using Minikube's Docker daemon:
```bash
eval $(minikube docker-env)
docker images
```

## 🆘 Emergency Recovery Procedures

### API Server Connectivity Issues ("connection to server localhost:8443 was refused")

This is the most common issue with Minikube deployments. Multiple recovery options are available:

#### Option 1: Automated Jenkins Recovery
The Jenkins pipeline now includes comprehensive API server recovery with:
- 25 retry attempts with progressive recovery strategies
- Automatic resource optimization
- Emergency script execution as last resort

#### Option 2: Manual Guided Recovery (Recommended)
```bash
# Run the interactive manual recovery script
chmod +x scripts/manual_recovery.sh
./scripts/manual_recovery.sh
```
This script provides:
- Step-by-step guidance with user interaction
- Resource checking and optimization
- Colored output for easy reading
- Progress indication during recovery

#### Option 3: Advanced Automated Recovery
```bash
# Run the advanced recovery script (fully automated)
chmod +x scripts/fix_minikube_advanced.sh
./scripts/fix_minikube_advanced.sh
```
This script provides:
- Complete system resource analysis
- Progressive Minikube configuration attempts
- Docker cleanup and process management
- Comprehensive final verification

#### Option 4: Complete Manual Reset
```bash
# Emergency manual reset (last resort)
minikube delete --all
docker system prune -af
minikube start --driver=docker --memory=2048 --cpus=1 --force
kubectl cluster-info  # Verify recovery
```

### Resource Optimization for Different EC2 Instances

#### t2.medium (4GB RAM, 2 vCPU)
```bash
minikube start --driver=docker --memory=2048 --cpus=1 --disk-size=10g
```

#### t2.large (8GB RAM, 2 vCPU) - Recommended
```bash
minikube start --driver=docker --memory=3072 --cpus=2 --disk-size=15g
```

#### t3.large (8GB RAM, 2 vCPU) - Better performance
```bash
minikube start --driver=docker --memory=4096 --cpus=2 --disk-size=20g
```

### Monitoring and Prevention

#### Health Check Script
```bash
#!/bin/bash
# Save as health_check.sh
while true; do
    if ! kubectl cluster-info --request-timeout=5s >/dev/null 2>&1; then
        echo "$(date): API server down! Running recovery..."
        ./scripts/fix_minikube_advanced.sh
    else
        echo "$(date): Cluster healthy"
    fi
    sleep 300  # Check every 5 minutes
done
```

#### Resource Monitoring
```bash
# Check system resources
free -h          # Memory usage
df -h           # Disk usage
docker system df # Docker space usage
```

### Getting Help

1. **Immediate Issues**: See `API_SERVER_TROUBLESHOOTING.md` for detailed diagnosis
2. **Jenkins Failures**: Check Jenkins console output for specific error messages
3. **System Issues**: Run `scripts/manual_recovery.sh` for guided troubleshooting
4. **Persistent Problems**: Contact system administrator with output from:
   ```bash
   minikube logs --length=100
   kubectl cluster-info
   free -h && df -h
   ```

### Success Indicators

The cluster is ready when these commands succeed:
```bash
kubectl cluster-info                    # API server responding
kubectl get nodes                       # Nodes ready
kubectl get pods -n kube-system        # System pods running
kubectl version --timeout=10s          # Full connectivity
```
