# 🚀 DevOps Chatbot - Persistent Deployment Guide

## Overview
This application is now configured for **persistent deployment** on Kubernetes. Once deployed, it will continue running until manually stopped.

## 🎯 Application Access

After deployment, your application will be accessible at:
```
http://<MINIKUBE_IP>:30080
```

To get the exact URL, run:
```bash
minikube ip
# Then access: http://[MINIKUBE_IP]:30080
```

## 📊 Monitoring Your Deployment

### Check Status
```bash
# Quick status check
./scripts/check_deployment_status.sh

# Manual checks
kubectl get pods -l app=devops-chatbot
kubectl get services devops-chatbot-service
kubectl get hpa devops-chatbot-hpa
```

### View Logs
```bash
# Application logs
kubectl logs -l app=devops-chatbot

# Follow live logs
kubectl logs -l app=devops-chatbot -f
```

### Health Check
```bash
# Test health endpoint
curl http://<MINIKUBE_IP>:30080/health
```

## 🔄 Managing Your Deployment

### Restart Application
```bash
kubectl rollout restart deployment/devops-chatbot-deployment
```

### Scale Application
```bash
# Scale to 3 replicas
kubectl scale deployment devops-chatbot-deployment --replicas=3

# Scale back to 1
kubectl scale deployment devops-chatbot-deployment --replicas=1
```

### Update Application
If you make code changes and want to update:
```bash
# 1. Build new image with new tag
docker build -t devops-chatbot:new-tag .

# 2. Update deployment
kubectl set image deployment/devops-chatbot-deployment chatbot-backend=devops-chatbot:new-tag

# 3. Check rollout status
kubectl rollout status deployment/devops-chatbot-deployment
```

## 🛑 Stopping the Application

### Option 1: Use Cleanup Script
```bash
./scripts/cleanup_k8s_manual.sh
```

### Option 2: Manual Cleanup
```bash
kubectl delete -f k8s-hpa.yaml
kubectl delete -f k8s-service.yaml
kubectl delete -f k8s-deployment.yaml
kubectl delete -f k8s-pvc.yaml
```

## 🔄 Redeploying After Cleanup

```bash
kubectl apply -f k8s-pvc.yaml
kubectl apply -f k8s-deployment.yaml
kubectl apply -f k8s-service.yaml
kubectl apply -f k8s-hpa.yaml
```

## 🔧 Configuration Details

### Persistence Features
- **Restart Policy**: `Always` - Pods restart automatically if they fail
- **Health Checks**: Application has `/health` endpoint for monitoring
- **Auto-scaling**: HPA configured to scale based on resource usage
- **Persistent Storage**: PVC for data persistence
- **No Auto-cleanup**: Application runs indefinitely until manually stopped

### Resource Allocation
- **Memory**: 512Mi request, 1Gi limit
- **CPU**: 500m request, 800m limit
- **Storage**: Persistent volume for data

### Probes Configuration
- **Startup Probe**: 10s initial delay, checks every 10s, up to 30 attempts
- **Liveness Probe**: 60s initial delay, checks every 30s
- **Readiness Probe**: 30s initial delay, checks every 10s

## 🆘 Troubleshooting

### Pod Not Starting
```bash
kubectl describe pod -l app=devops-chatbot
kubectl logs -l app=devops-chatbot
```

### Service Not Accessible
```bash
kubectl get endpoints devops-chatbot-service
minikube service devops-chatbot-service --url
```

### Application Errors
```bash
kubectl logs -l app=devops-chatbot --tail=50
curl http://<MINIKUBE_IP>:30080/health
```

### Complete Reset
If you need to completely reset:
```bash
./scripts/cleanup_k8s_manual.sh
minikube delete
minikube start
# Then redeploy using Jenkins pipeline
```

## 📈 Monitoring & Observability

### Resource Usage
```bash
kubectl top pods -l app=devops-chatbot
kubectl top nodes
```

### Events
```bash
kubectl get events --sort-by=.metadata.creationTimestamp | grep devops-chatbot
```

### HPA Status
```bash
kubectl get hpa devops-chatbot-hpa
kubectl describe hpa devops-chatbot-hpa
```

---

## 🎉 Success! Your DevOps Chatbot is now running persistently on Kubernetes! 

The application will continue running and automatically restart if any issues occur, ensuring high availability for your DevOps learning assistant.
