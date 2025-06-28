#!/bin/bash

# Advanced Minikube Recovery Script for API Server Issues
# This script addresses critical Minikube API server connectivity problems

echo "🚨 ADVANCED MINIKUBE RECOVERY SCRIPT"
echo "======================================="

# Function to check API server connectivity
check_api_server() {
    kubectl cluster-info --request-timeout=5s >/dev/null 2>&1
}

# Function to check system resources
check_resources() {
    echo "🔍 Checking system resources..."
    
    # Check memory
    TOTAL_MEM=$(free -m | awk 'NR==2{printf "%.0f", $2}')
    AVAIL_MEM=$(free -m | awk 'NR==2{printf "%.0f", $7}')
    echo "💾 Total Memory: ${TOTAL_MEM}MB, Available: ${AVAIL_MEM}MB"
    
    if [ "$AVAIL_MEM" -lt 1500 ]; then
        echo "⚠️ WARNING: Low available memory (${AVAIL_MEM}MB < 1500MB)"
        return 1
    fi
    
    # Check disk space
    DISK_AVAIL=$(df -h / | awk 'NR==2 {print $4}' | sed 's/G//')
    echo "💿 Available disk space: ${DISK_AVAIL}GB"
    
    if [ "$DISK_AVAIL" -lt 2 ]; then
        echo "⚠️ WARNING: Low disk space (${DISK_AVAIL}GB < 2GB)"
        return 1
    fi
    
    return 0
}

# Step 1: System Resource Check
echo "Step 1: Checking system resources..."
if ! check_resources; then
    echo "❌ Insufficient system resources detected"
    echo "💡 Consider upgrading EC2 instance or freeing up resources"
    # Continue anyway but use minimal settings
    USE_MINIMAL=true
else
    echo "✅ System resources sufficient"
    USE_MINIMAL=false
fi

# Step 2: Complete Docker cleanup
echo "Step 2: Comprehensive Docker cleanup..."
docker system prune -af --volumes || true
docker network prune -f || true
docker volume prune -f || true

# Step 3: Kill any hanging processes
echo "Step 3: Killing hanging processes..."
pkill -f minikube || true
pkill -f kubectl || true
pkill -f kubelet || true
sleep 5

# Step 4: Remove all Minikube data
echo "Step 4: Removing all Minikube data..."
minikube delete --all || true
rm -rf ~/.minikube || true
rm -rf ~/.kube || true

# Step 5: Restart Docker daemon (if possible)
echo "Step 5: Attempting Docker daemon restart..."
if command -v systemctl >/dev/null 2>&1; then
    sudo systemctl restart docker || echo "Could not restart Docker daemon"
    sleep 10
fi

# Step 6: Start Minikube with progressive resource allocation
echo "Step 6: Starting Minikube with optimized configuration..."

if [ "$USE_MINIMAL" = true ]; then
    echo "🔧 Using minimal resource configuration..."
    MEMORY=1536
    CPUS=1
    DISK=10g
else
    echo "🔧 Using standard resource configuration..."
    MEMORY=2560
    CPUS=2
    DISK=15g
fi

# Try multiple start configurations in order of preference
START_CONFIGS=(
    "--driver=docker --memory=$MEMORY --cpus=$CPUS --disk-size=$DISK --no-vtx-check"
    "--driver=docker --memory=1536 --cpus=1 --disk-size=10g --no-vtx-check --force"
    "--driver=docker --memory=1024 --cpus=1 --disk-size=8g --no-vtx-check --force --extra-config=kubeadm.skip-phases=addon/kube-proxy"
)

MINIKUBE_STARTED=false
for config in "${START_CONFIGS[@]}"; do
    echo "🚀 Trying configuration: $config"
    
    if minikube start $config; then
        echo "✅ Minikube started successfully with config: $config"
        MINIKUBE_STARTED=true
        break
    else
        echo "❌ Failed with config: $config"
        minikube delete || true
        sleep 10
    fi
done

if [ "$MINIKUBE_STARTED" = false ]; then
    echo "❌ All Minikube start configurations failed"
    exit 1
fi

# Step 7: Wait for API server with extensive timeout
echo "Step 7: Waiting for API server to be ready..."
API_READY=false
for i in {1..30}; do
    echo "⏳ API server check $i/30..."
    
    if check_api_server && kubectl get nodes --request-timeout=5s >/dev/null 2>&1; then
        echo "✅ API server is ready!"
        API_READY=true
        break
    fi
    
    # Progressive interventions
    if [ $i -eq 10 ]; then
        echo "🔧 Restarting kubelet..."
        minikube ssh 'sudo systemctl restart kubelet' || true
    elif [ $i -eq 20 ]; then
        echo "🔧 Restarting API server components..."
        minikube ssh 'sudo systemctl restart kubelet && sudo docker restart $(sudo docker ps -q --filter name=k8s_kube-apiserver)' || true
    fi
    
    sleep 10
done

# Step 8: Final verification
if [ "$API_READY" = true ]; then
    echo "✅ RECOVERY SUCCESSFUL!"
    echo "🔍 Final cluster status:"
    minikube status
    kubectl cluster-info
    kubectl get nodes
    kubectl get pods -n kube-system
else
    echo "❌ RECOVERY FAILED - API server still not responding"
    echo "🔍 Final diagnostics:"
    minikube status || true
    minikube logs --length=50 || true
    exit 1
fi

echo "🎉 Minikube recovery completed successfully!"
