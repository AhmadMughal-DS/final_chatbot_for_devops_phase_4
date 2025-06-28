# Minikube API Server Recovery - Quick Reference

## Problem
Error: "The connection to the server localhost:8443 was refused - did you specify the right host or port?"

## 4 Recovery Methods (in order of preference)

### 1. 🤖 Automated Jenkins Recovery
**Status**: Enhanced in Jenkins pipeline
- **What it does**: 25 retry attempts with progressive recovery strategies
- **When to use**: Automatic during Jenkins builds
- **Manual trigger**: Run Jenkins pipeline again

### 2. 👤 Manual Guided Recovery (Recommended for manual fixes)
**Script**: `scripts/manual_recovery.sh`
- **What it does**: Step-by-step interactive recovery with user confirmation
- **When to use**: When you want to understand what's happening
- **Features**: Colored output, progress indication, resource checking
```bash
chmod +x scripts/manual_recovery.sh
./scripts/manual_recovery.sh
```

### 3. ⚡ Advanced Automated Recovery
**Script**: `scripts/fix_minikube_advanced.sh`
- **What it does**: Comprehensive automated reset and recovery
- **When to use**: When you want hands-off recovery
- **Features**: Resource analysis, progressive configurations, comprehensive verification
```bash
chmod +x scripts/fix_minikube_advanced.sh
./scripts/fix_minikube_advanced.sh
```

### 4. 🚨 Emergency Manual Reset
**Commands**: Direct Minikube reset
- **What it does**: Complete cluster destruction and recreation
- **When to use**: When all else fails
```bash
minikube delete --all
docker system prune -af
minikube start --driver=docker --memory=2048 --cpus=1 --force
```

## Resource Recommendations by EC2 Instance

| Instance Type | Memory | CPUs | Disk | Command |
|---------------|--------|------|------|---------|
| t2.medium | 2048MB | 1 | 10g | `minikube start --driver=docker --memory=2048 --cpus=1 --disk-size=10g` |
| t2.large | 3072MB | 2 | 15g | `minikube start --driver=docker --memory=3072 --cpus=2 --disk-size=15g` |
| t3.large | 4096MB | 2 | 20g | `minikube start --driver=docker --memory=4096 --cpus=2 --disk-size=20g` |

## Quick Verification Commands
```bash
# Test API server
kubectl cluster-info --request-timeout=5s

# Check node status
kubectl get nodes

# Verify system pods
kubectl get pods -n kube-system

# Complete verification
kubectl version --timeout=10s
```

## Documentation References
- **Detailed troubleshooting**: `API_SERVER_TROUBLESHOOTING.md`
- **Complete deployment guide**: `KUBERNETES_DEPLOYMENT.md`
- **General Minikube issues**: `MINIKUBE_TROUBLESHOOTING.md`

## Success Indicators
✅ All verification commands return successfully without timeouts
✅ `minikube status` shows "Running"
✅ API server accessible at localhost:8443
✅ System pods in "Running" state
