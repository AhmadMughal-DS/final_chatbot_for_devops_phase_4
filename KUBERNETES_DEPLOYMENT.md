# Kubernetes Deployment Guide for DevOps Chatbot

## Prerequisites
1. Minikube installed and running on AWS EC2
2. kubectl configured to work with your Minikube cluster
3. Docker image built locally in Minikube

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
