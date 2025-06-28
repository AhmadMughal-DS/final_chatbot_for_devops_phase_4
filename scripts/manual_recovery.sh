#!/bin/bash

# Manual Minikube Recovery Script for API Server Issues
# Run this script when Jenkins pipeline fails with API server connectivity issues

echo "🚨 MANUAL MINIKUBE RECOVERY FOR API SERVER ISSUES"
echo "=================================================="
echo "This script will attempt to resolve the 'connection to server localhost:8443 was refused' error"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check API server connectivity
check_api_server() {
    kubectl cluster-info --request-timeout=5s >/dev/null 2>&1
}

# Function to wait for user input
wait_for_user() {
    echo ""
    read -p "Press Enter to continue or Ctrl+C to abort..."
    echo ""
}

# Step 0: Initial diagnosis
print_status "Step 0: Initial diagnosis"
echo "Current Minikube status:"
minikube status || print_warning "Minikube status command failed"

echo ""
echo "Testing API server connectivity:"
if check_api_server; then
    print_success "API server is already responding!"
    kubectl cluster-info
    exit 0
else
    print_error "API server is not responding - starting recovery process"
fi

wait_for_user

# Step 1: Check system resources
print_status "Step 1: Checking system resources"
echo "Memory usage:"
free -h
echo ""
echo "Disk usage:"
df -h
echo ""
echo "CPU information:"
nproc
echo ""

# Calculate available memory
AVAIL_MEM=$(free -m | awk 'NR==2{printf "%.0f", $7}')
if [ "$AVAIL_MEM" -lt 1500 ]; then
    print_warning "Low available memory: ${AVAIL_MEM}MB (recommended: >1500MB)"
    print_warning "Consider closing other applications or upgrading EC2 instance"
fi

wait_for_user

# Step 2: Docker system check and cleanup
print_status "Step 2: Docker system check and cleanup"
echo "Docker version:"
docker version || print_error "Docker is not responding properly"

echo ""
echo "Docker system information:"
docker system df

echo ""
print_status "Cleaning up Docker system..."
docker system prune -f
print_success "Docker cleanup completed"

wait_for_user

# Step 3: Kill hanging processes
print_status "Step 3: Killing any hanging processes"
pkill -f minikube && print_status "Killed minikube processes" || print_status "No minikube processes to kill"
pkill -f kubectl && print_status "Killed kubectl processes" || print_status "No kubectl processes to kill"
pkill -f kubelet && print_status "Killed kubelet processes" || print_status "No kubelet processes to kill"
sleep 5

# Step 4: Complete Minikube reset
print_status "Step 4: Complete Minikube reset"
print_warning "This will delete all existing Minikube data and clusters"
wait_for_user

minikube delete --all || print_warning "Minikube delete failed or no clusters to delete"
rm -rf ~/.minikube || print_warning "Could not remove ~/.minikube directory"
rm -rf ~/.kube || print_warning "Could not remove ~/.kube directory"
print_success "Minikube reset completed"

# Step 5: Start Minikube with optimized settings
print_status "Step 5: Starting Minikube with optimized settings"

# Determine optimal resource allocation
if [ "$AVAIL_MEM" -gt 4000 ]; then
    MEMORY=3072
    CPUS=2
    print_status "Using high resource configuration (Memory: ${MEMORY}MB, CPUs: ${CPUS})"
elif [ "$AVAIL_MEM" -gt 2500 ]; then
    MEMORY=2048
    CPUS=2
    print_status "Using medium resource configuration (Memory: ${MEMORY}MB, CPUs: ${CPUS})"
else
    MEMORY=1536
    CPUS=1
    print_status "Using minimal resource configuration (Memory: ${MEMORY}MB, CPUs: ${CPUS})"
fi

echo ""
print_status "Starting Minikube cluster..."
if minikube start --driver=docker --memory=$MEMORY --cpus=$CPUS --disk-size=15g --no-vtx-check; then
    print_success "Minikube started successfully!"
else
    print_error "Initial start failed, trying with minimal configuration..."
    if minikube start --driver=docker --memory=1024 --cpus=1 --disk-size=10g --no-vtx-check --force; then
        print_success "Minikube started with minimal configuration!"
    else
        print_error "All start attempts failed"
        exit 1
    fi
fi

# Step 6: Wait for API server with progress indication
print_status "Step 6: Waiting for API server to be ready"
API_READY=false
for i in {1..20}; do
    printf "Attempt %d/20: " $i
    if check_api_server; then
        print_success "API server is ready!"
        API_READY=true
        break
    else
        printf "Not ready, waiting...\n"
        
        # Progressive interventions
        if [ $i -eq 10 ]; then
            print_status "Halfway point - restarting kubelet..."
            minikube ssh 'sudo systemctl restart kubelet' || true
        elif [ $i -eq 15 ]; then
            print_status "Restarting API server components..."
            minikube ssh 'sudo systemctl restart kubelet && sudo docker restart $(sudo docker ps -q --filter name=k8s_kube-apiserver)' || true
        fi
        
        sleep 15
    fi
done

# Step 7: Final verification
if [ "$API_READY" = true ]; then
    print_success "RECOVERY SUCCESSFUL!"
    echo ""
    print_status "Final cluster status:"
    minikube status
    echo ""
    kubectl cluster-info
    echo ""
    kubectl get nodes
    echo ""
    kubectl get pods -n kube-system
    
    # Enable metrics server for HPA
    print_status "Enabling metrics server for HPA..."
    minikube addons enable metrics-server || print_warning "Failed to enable metrics-server"
    
    print_success "Cluster is ready for deployment!"
else
    print_error "RECOVERY FAILED - API server still not responding"
    echo ""
    print_status "Final diagnostics:"
    minikube status || true
    echo ""
    print_status "Minikube logs (last 50 lines):"
    minikube logs --length=50 || true
    echo ""
    print_error "Manual intervention required. Consider:"
    echo "1. Upgrading EC2 instance size"
    echo "2. Checking Docker daemon health"
    echo "3. Reviewing system logs"
    echo "4. Contacting system administrator"
    exit 1
fi

print_success "🎉 Manual recovery completed successfully!"
echo ""
print_status "Next steps:"
echo "1. Deploy your application using: kubectl apply -f k8s-*.yaml"
echo "2. Check deployment status: kubectl get pods"
echo "3. Access application: minikube service devops-chatbot-nodeport --url"
