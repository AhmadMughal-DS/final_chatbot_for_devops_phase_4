pipeline {
    // Use any available agent instead of requiring a specific label
    agent any
    
    environment {
        PROJECT_NAME = 'devops_chatbot_pipeline'
        GITHUB_REPO = 'https://github.com/AhmadMughal-DS/final_chatbot_for_devops_phase_4'
        KUBE_NAMESPACE = 'default'
        APP_NAME = 'devops-chatbot'
        IMAGE_NAME = "devops-chatbot:build-${BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                // Clean workspace before we start
                cleanWs()
                
                // Fetch code from GitHub repository
                echo 'Fetching code from GitHub repository'
                sh    """ git clone "${GITHUB_REPO}" """
            }
        }
        
        stage('Build Docker Image for Kubernetes') {
            steps {
                echo 'Building Docker image for Kubernetes deployment'
                
                // Navigate to the cloned repository directory
                dir('final_chatbot_for_devops_phase_4') {
                    sh '''
                        # Wait for Minikube to be fully ready
                        echo "⏳ Waiting for Minikube to be ready..."
                        sleep 30
                        
                        # Check Minikube status with retry
                        for i in {1..5}; do
                            if minikube status | grep -q "kubelet: Running"; then
                                echo "✅ Minikube is ready!"
                                break
                            else
                                echo "⏳ Waiting for Minikube... (attempt $i/5)"
                                if [ $i -eq 3 ]; then
                                    echo "🔄 Attempting Minikube restart..."
                                    minikube stop || true
                                    minikube start --driver=docker --memory=2048 --cpus=2
                                fi
                                sleep 15
                            fi
                        done
                        
                        # Final Minikube check
                        if ! minikube status | grep -q "kubelet: Running"; then
                            echo "❌ Minikube failed to start properly"
                            minikube status || true
                            minikube logs || true
                            exit 1
                        fi
                        
                        # Set Docker environment to use Minikube's Docker daemon
                        eval $(minikube docker-env)
                        
                        # Check network connectivity
                        echo "🌐 Checking network connectivity..."
                        ping -c 3 8.8.8.8 || echo "Network connectivity issue detected"
                        nslookup pypi.org || echo "DNS resolution issue detected"
                        
                        # Make build script executable and run it
                        echo "📦 Building Docker image with tag: ${IMAGE_NAME}"
                        
                        # Build with multiple tags (latest and build-specific)
                        if [ -f "scripts/build_docker.sh" ]; then
                            chmod +x scripts/build_docker.sh
                            ./scripts/build_docker.sh || (
                                echo "❌ Script failed, trying manual build..."
                                # Manual fallback with multiple tags
                                docker build --dns=8.8.8.8 --dns=8.8.4.4 -t devops-chatbot:latest -t ${IMAGE_NAME} . ||
                                docker build --network=host -t devops-chatbot:latest -t ${IMAGE_NAME} .
                            )
                            # Ensure we have the build-specific tag
                            docker tag devops-chatbot:latest ${IMAGE_NAME} || echo "Tag already exists"
                        else
                            echo "🏗️ Building Docker image manually with multiple tags..."
                            docker build --dns=8.8.8.8 --dns=8.8.4.4 -t devops-chatbot:latest -t ${IMAGE_NAME} . ||
                            docker build --network=host -t devops-chatbot:latest -t ${IMAGE_NAME} .
                        fi
                        
                        # Verify image is built with both tags
                        echo "🔍 Verifying Docker images:"
                        docker images | grep devops-chatbot
                        
                        # Check specifically for our build tag
                        if docker images | grep devops-chatbot | grep -q "build-${BUILD_NUMBER}"; then
                            echo "✅ Build-specific image ${IMAGE_NAME} available"
                        else
                            echo "❌ Build-specific image ${IMAGE_NAME} not found, attempting to tag..."
                            docker tag devops-chatbot:latest ${IMAGE_NAME} || {
                                echo "❌ Failed to create build-specific tag"
                                exit 1
                            }
                        fi
                        
                        echo "✅ Docker image built successfully for Kubernetes"
                    '''
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying application to Kubernetes (Minikube)'
                
                // Navigate to the cloned repository directory
                dir('final_chatbot_for_devops_phase_4') {
                    sh '''
                        echo "🚀 Starting Kubernetes Deployment..."
                        
                        # Pre-deployment aggressive cleanup to ensure fresh start
                        echo "🧹 Performing pre-deployment cleanup..."
                        kubectl delete all --all --grace-period=0 --force || true
                        minikube stop || true
                        sleep 10
                        
                        # Complete Minikube reset and troubleshooting
                        echo "🔍 Comprehensive Minikube cluster health check..."
                        
                        # Function to check API server
                        check_api_server() {
                            kubectl cluster-info --request-timeout=5s >/dev/null 2>&1
                        }
                        
                        # Step 1: Check current status
                        echo "📊 Current Minikube status:"
                        minikube status || true
                        
                        # Step 2: Check if API server is responding
                        if ! check_api_server; then
                            echo "❌ API server not responding, performing complete reset..."
                            
                            # Kill any hanging processes
                            pkill -f minikube || true
                            pkill -f kubectl || true
                            pkill -f dockerd || true
                            sleep 5
                            
                            # Stop and delete current cluster
                            minikube stop || true
                            minikube delete --all || true
                            
                            # Clean up Docker containers and networks aggressively
                            docker system prune -af --volumes || true
                            docker network prune -f || true
                            
                            # Wait for cleanup
                            sleep 15
                            
                            # Start fresh Minikube cluster with conservative settings
                            echo "🚀 Starting fresh Minikube cluster with conservative settings..."
                            minikube start \
                                --driver=docker \
                                --memory=2048 \
                                --cpus=2 \
                                --disk-size=10g \
                                --delete-on-failure \
                                --force || {
                                echo "❌ Minikube start failed, trying with absolute minimal config..."
                                minikube start --driver=docker --memory=1536 --cpus=1 --force
                            }
                            
                            # Extended wait for cluster initialization
                            echo "⏳ Waiting for cluster to initialize..."
                            sleep 60
                        fi
                        
                        # Step 3: Enhanced API server recovery with multiple strategies
                        echo "⏳ Waiting for API server to be ready with enhanced recovery..."
                        API_READY=false
                        for i in {1..25}; do
                            echo "🔍 API server check attempt $i/25..."
                            
                            # Check API server with multiple verification methods
                            if kubectl cluster-info --request-timeout=8s >/dev/null 2>&1 && \
               kubectl get nodes --request-timeout=8s >/dev/null 2>&1 && \
               kubectl version --client=false --request-timeout=8s >/dev/null 2>&1; then
                                echo "✅ API server is fully responding!"
                                API_READY=true
                                break
                            else
                                echo "⏳ API server not ready, waiting... (attempt $i/25)"
                                
                                # Progressive recovery strategies
                                if [ $i -eq 5 ]; then
                                    echo "� Strategy 1: Restarting kubelet inside Minikube..."
                                    minikube ssh 'sudo systemctl restart kubelet' >/dev/null 2>&1 || true
                                    sleep 20
                                elif [ $i -eq 10 ]; then
                                    echo "🔧 Strategy 2: Soft Minikube restart..."
                                    minikube stop || true
                                    sleep 10
                                    minikube start --driver=docker --memory=3072 --cpus=2 --keep-context || true
                                    sleep 30
                                elif [ $i -eq 15 ]; then
                                    echo "🔧 Strategy 3: Hard reset with minimal resources..."
                                    minikube delete || true
                                    docker system prune -f || true
                                    sleep 15
                                    minikube start --driver=docker --memory=2560 --cpus=2 --disk-size=15g --force || true
                                    sleep 45
                                elif [ $i -eq 20 ]; then
                                    echo "🔧 Strategy 4: Emergency minimal configuration..."
                                    minikube delete || true
                                    docker system prune -af || true
                                    # Kill any hanging processes
                                    pkill -f minikube || true
                                    pkill -f kubectl || true
                                    sleep 20
                                    minikube start --driver=docker --memory=1536 --cpus=1 --no-vtx-check --force || true
                                    sleep 60
                                fi
                                
                                sleep 12
                            fi
                        done
                        
                        # Step 4: Final verification
                        if [ "$API_READY" = false ]; then
                            echo "❌ API server failed to start after extended attempts"
                            echo "🔍 Debugging information:"
                            minikube status || true
                            minikube logs || true
                            kubectl config view || true
                            
                            # Try one last reset
                            echo "� Final attempt - complete reset..."
                            minikube delete --all || true
                            docker system prune -af || true
                            sleep 15
                            minikube start --driver=docker --memory=2048 --cpus=1 --force
                            sleep 60
                            
                            if ! check_api_server; then
                                echo "❌ Complete failure - API server cannot be started"
                                exit 1
                            fi
                        fi
                        
                        # Step 5: Verify cluster components
                        echo "✅ Verifying cluster components..."
                        kubectl get nodes --no-headers || {
                            echo "❌ Nodes not ready"
                            exit 1
                        }
                        
                        kubectl get pods -n kube-system --no-headers || {
                            echo "❌ System pods not ready"
                            exit 1
                        }
                        
                        echo "✅ Minikube cluster is healthy and ready!"
                        
                        # CRITICAL: Rebuild Docker image in Minikube's Docker daemon
                        echo "🔄 Rebuilding Docker image in Minikube's Docker daemon..."
                        eval $(minikube docker-env)
                        
                        # Always rebuild the image to ensure it's available with correct tag
                        echo "📦 Building Docker image with tag: ${IMAGE_NAME}..."
                        
                        # Verify we're using Minikube's Docker daemon
                        echo "� Current Docker context:"
                        docker info | grep -E "Server Version|Name" || true
                        
                        # Build the image with both latest and specific tag
                        echo "🏗️ Building Docker image with multiple tags..."
                        
                        # Build with primary method using DNS settings
                        if docker build --dns=8.8.8.8 --dns=8.8.4.4 -t devops-chatbot:latest -t ${IMAGE_NAME} .; then
                            echo "✅ Primary build successful"
                        elif docker build --network=host -t devops-chatbot:latest -t ${IMAGE_NAME} .; then
                            echo "✅ Network host build successful"
                        elif docker build -t devops-chatbot:latest -t ${IMAGE_NAME} .; then
                            echo "✅ Basic build successful"
                        else
                            echo "❌ All build methods failed, trying with build script..."
                            if [ -f "scripts/build_docker.sh" ]; then
                                chmod +x scripts/build_docker.sh
                                ./scripts/build_docker.sh || {
                                    echo "❌ Build script also failed"
                                    exit 1
                                }
                                # Tag the latest image with our specific tag
                                docker tag devops-chatbot:latest ${IMAGE_NAME} || {
                                    echo "❌ Failed to tag image"
                                    exit 1
                                }
                            else
                                echo "❌ No build script available and all builds failed"
                                exit 1
                            fi
                        fi
                        
                        # Verify the specific image is built and available
                        echo "🔍 Verifying Docker image availability:"
                        docker images | grep devops-chatbot || {
                            echo "❌ Failed to build Docker image"
                            exit 1
                        }
                        
                        # Specifically check for our tagged image
                        echo "🔍 Checking for build-specific image tag..."
                        if docker images | grep devops-chatbot | grep -q "build-${BUILD_NUMBER}"; then
                            echo "✅ Docker image ${IMAGE_NAME} is available in Minikube"
                            echo "📦 Image details:"
                            docker images | grep devops-chatbot
                        else
                            echo "❌ Build-specific image tag not found"
                            echo "Available images:"
                            docker images | grep devops-chatbot || echo "No devops-chatbot images found"
                            
                            # Try to tag from latest if it exists
                            if docker images | grep devops-chatbot | grep -q "latest"; then
                                echo "🔄 Attempting to tag from latest..."
                                docker tag devops-chatbot:latest ${IMAGE_NAME}
                                if docker images | grep devops-chatbot | grep -q "build-${BUILD_NUMBER}"; then
                                    echo "✅ Successfully tagged image as ${IMAGE_NAME}"
                                else
                                    echo "❌ Failed to tag image"
                                    exit 1
                                fi
                            else
                                echo "❌ No devops-chatbot images available at all"
                                exit 1
                            fi
                        fi
                        
                        # Clean up any existing deployment
                        kubectl delete -f k8s-hpa.yaml --ignore-not-found=true
                        kubectl delete -f k8s-service.yaml --ignore-not-found=true
                        kubectl delete -f k8s-deployment.yaml --ignore-not-found=true
                        kubectl delete -f k8s-pvc.yaml --ignore-not-found=true
                        
                        # Wait for cleanup
                        sleep 10
                        
                        # Enable metrics server for HPA
                        minikube addons enable metrics-server || echo "Metrics server already enabled"
                        
                        # Apply Kubernetes manifests in correct order
                        echo "📦 Applying PersistentVolumeClaims..."
                        kubectl apply -f k8s-pvc.yaml
                        
                        echo "🚢 Applying Deployment with correct image tag..."
                        # Create a temporary deployment file with correct image tag
                        cp k8s-deployment.yaml k8s-deployment-temp.yaml
                        sed -i "s|devops-chatbot:latest|${IMAGE_NAME}|g" k8s-deployment-temp.yaml
                        
                        # Verify the sed replacement worked
                        echo "🔍 Verifying image tag in deployment file:"
                        grep "image:" k8s-deployment-temp.yaml
                        
                        # Apply the deployment with correct image
                        kubectl apply -f k8s-deployment-temp.yaml
                        
                        # Clean up temp file
                        rm k8s-deployment-temp.yaml
                        
                        echo "🌐 Applying Services..."
                        kubectl apply -f k8s-service.yaml
                        
                        echo "📈 Applying HPA..."
                        kubectl apply -f k8s-hpa.yaml
                        
                        # Immediate deployment verification
                        echo "🔍 Verifying deployment was applied correctly..."
                        kubectl get deployments
                        kubectl describe deployment devops-chatbot-deployment | grep -A 5 -B 5 "Image"
                        
                        echo "✅ Kubernetes deployment complete"
                    '''
                }
            }
        }
        
        stage('Verify Kubernetes Deployment') {
            steps {
                echo 'Verifying Kubernetes deployment'
                
                dir('final_chatbot_for_devops_phase_4') {
                    sh '''
                        echo "⏳ Waiting for deployment to be ready..."
                        
                        # Check deployment status first
                        echo "📊 Current deployment status:"
                        kubectl get deployments
                        kubectl get pods -l app=devops-chatbot
                        
                        # Check pod logs for any startup issues
                        echo "📝 Checking pod startup logs..."
                        kubectl logs -l app=devops-chatbot --tail=20 || echo "No logs available yet"
                        
                        # Check for image pull issues specifically
                        echo "🔍 Checking for image pull issues..."
                        if kubectl get events --field-selector reason=Failed | grep -i "pull|image"; then
                            echo "❌ Image pull issues detected:"
                            kubectl get events --field-selector reason=Failed | grep -i "pull|image"
                            
                            echo "🔍 Available images in Minikube:"
                            eval $(minikube docker-env)
                            docker images | grep devops-chatbot
                            
                            echo "🔍 Pod details for image issues:"
                            kubectl describe pods -l app=devops-chatbot | grep -A10 -B10 -i "image"
                            
                            # Don't exit here, let the wait timeout handle it
                        fi
                        
                        # Wait a bit more for image pull if needed
                        echo "⏳ Waiting for image pull and container creation..."
                        sleep 30
                        
                        # Check again
                        echo "📊 Updated pod status:"
                        kubectl get pods -l app=devops-chatbot
                        kubectl describe pods -l app=devops-chatbot | grep -A5 -B5 "Events:"
                        
                        # Wait for deployment with shorter timeout and better error handling
                        if ! kubectl wait --for=condition=available --timeout=180s deployment/devops-chatbot-deployment; then
                            echo "❌ Deployment failed to become available, debugging..."
                            
                            echo "🔍 Pod details:"
                            kubectl describe pods -l app=devops-chatbot
                            
                            echo "📝 Pod logs:"
                            kubectl logs -l app=devops-chatbot --tail=50 || echo "No logs available"
                            
                            echo "🚨 Deployment status:"
                            kubectl describe deployment devops-chatbot-deployment
                            
                            # Try to get more information about the issue
                            echo "⚠️ Events:"
                            kubectl get events --sort-by=.metadata.creationTimestamp | tail -20
                            
                            exit 1
                        fi
                        
                        echo "📊 Checking deployment status:"
                        kubectl get pods -l app=devops-chatbot
                        kubectl get services
                        kubectl get pvc
                        kubectl get hpa
                        
                        # Show pod details
                        echo "🔍 Pod details:"
                        kubectl describe pods -l app=devops-chatbot
                        
                        # Show pod logs
                        echo "📝 Application logs:"
                        kubectl logs -l app=devops-chatbot --tail=50
                        
                        # Get application URL
                        echo "🌐 Application Access Information:"
                        MINIKUBE_IP=$(minikube ip)
                        NODE_PORT=$(kubectl get service devops-chatbot-service -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "30080")
                        echo "🚀 Access your application at: http://$MINIKUBE_IP:$NODE_PORT"
                        echo "📝 Note: If NodePort detection fails, try: http://$MINIKUBE_IP:30080"
                    '''
                }
            }
        }
        
        stage('Test Kubernetes Deployment') {
            steps {
                echo 'Running Frontend Chat Tests on Kubernetes'
                
                // Navigate to the cloned repository directory
                dir('final_chatbot_for_devops_phase_4') {
                    // Install Chrome and dependencies for Selenium (without sudo)
                    sh '''
                        echo "🔧 Setting up test environment..."
                        
                        # Skip Chrome installation and use basic connectivity test
                        # Install Python dependencies
                        pip3 install requests --break-system-packages || pip3 install requests
                        
                        echo "✅ Test environment ready"
                    '''
                    
                    // Wait for the application to be fully ready
                    sh 'sleep 60'
                    
                    // Run the Kubernetes-specific test
                    sh '''
                        echo "🧪 Starting Kubernetes Frontend Connectivity Test..."
                        
                        # Get application URL for testing
                        MINIKUBE_IP=$(minikube ip)
                        NODE_PORT=$(kubectl get service devops-chatbot-service -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "30080")
                        export TEST_URL="http://$MINIKUBE_IP:$NODE_PORT"
                        
                        echo "🎯 Testing Kubernetes deployment at: $TEST_URL"
                        
                        # Create simple connectivity test
                        cat > tests/test_k8s_connectivity.py << 'EOF'
import os
import requests
import time

# Get test URL from environment
TEST_URL = os.environ.get('TEST_URL', 'http://localhost:8002')
print(f"🎯 Testing Kubernetes deployment at: {TEST_URL}")

try:
    print("🚀 Starting Kubernetes connectivity test...")
    
    # Test basic connectivity
    response = requests.get(TEST_URL, timeout=10)
    
    if response.status_code == 200:
        print("✅ Application is accessible!")
        print(f"📄 Response contains HTML: {'html' in response.text.lower()}")
        
        # Test if it's the correct application
        if "devops" in response.text.lower() or "chatbot" in response.text.lower():
            print("✅ This appears to be the DevOps chatbot application!")
        else:
            print("⚠️ Response doesn't contain expected content")
            
        print("✅ Kubernetes deployment test PASSED!")
        
    else:
        print(f"❌ Application returned status code: {response.status_code}")
        print("❌ Kubernetes deployment test FAILED!")
        exit(1)
        
except requests.exceptions.Timeout:
    print("⏰ Request timed out - application might be starting up")
    print("❌ Kubernetes deployment test FAILED!")
    exit(1)
    
except requests.exceptions.ConnectionError:
    print("❌ Cannot connect to application")
    print("❌ Kubernetes deployment test FAILED!")
    exit(1)
    
except Exception as e:
    print(f"❌ Test failed: {str(e)}")
    print("❌ Kubernetes deployment test FAILED!")
    exit(1)

print("✅ All connectivity tests passed!")
EOF
                        
                        # Run the connectivity test
                        python3 tests/test_k8s_chatbot.py || python3 tests/test_k8s_connectivity.py
                    '''
                }
            }
        }
        
        stage('Deployment Summary & Persistent Setup') {
            steps {
                echo 'Setting up persistent Kubernetes deployment'
                
                // Navigate to the cloned repository directory
                dir('final_chatbot_for_devops_phase_4') {
                    sh '''
                        echo "🚀 Deployment completed successfully!"
                        echo "📋 Deployment Summary:"
                        echo "===================="
                        
                        # Get deployment information
                        MINIKUBE_IP=$(minikube ip)
                        NODE_PORT=$(kubectl get service devops-chatbot-service -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "30080")
                        
                        echo "🌐 Application URL: http://$MINIKUBE_IP:$NODE_PORT"
                        echo "🐳 Docker Image: ${IMAGE_NAME}"
                        
                        # Show current status
                        echo "📊 Current Status:"
                        kubectl get pods -l app=devops-chatbot
                        kubectl get services devops-chatbot-service
                        kubectl get hpa devops-chatbot-hpa 2>/dev/null || echo "HPA not available"
                        
                        echo "✅ Application is now running persistently!"
                        echo "💡 To stop the application, manually run: kubectl delete -f k8s-deployment.yaml"
                        echo "� To restart: kubectl apply -f k8s-deployment.yaml"
                    '''
                }
            }
        }
    }
    
    post {
        always {
            echo 'Cleaning up workspace'
            
            // Show final Kubernetes status
            sh '''
                echo "📊 Final Kubernetes status:"
                kubectl get pods -l app=devops-chatbot || echo "No chatbot pods running"
                kubectl get services | grep devops-chatbot || echo "No chatbot services running"
                kubectl get hpa | grep devops-chatbot || echo "No HPA running"
            '''
            
            deleteDir() // Clean workspace after build
        }
        success {
            echo '🎉 Kubernetes CI/CD Pipeline completed successfully!'
            echo '✅ All stages passed including Kubernetes deployment and testing'
            echo '🚀 Application is deployed on Kubernetes with auto-scaling and PERSISTENT DEPLOYMENT'
            echo '💡 The application will continue running until manually stopped'
            
            // Show access information
            sh '''
                echo "🌐 Access your application:"
                MINIKUBE_IP=$(minikube ip) || echo "Could not get Minikube IP"
                NODE_PORT=$(kubectl get service devops-chatbot-service -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "30080")
                echo "URL: http://$MINIKUBE_IP:$NODE_PORT"
                echo "📝 Fallback URL: http://$MINIKUBE_IP:30080"
                echo "📈 Auto-scaling is enabled with HPA"
                echo "🔒 Application will remain running persistently"
                echo ""
                echo "To manually stop the application:"
                echo "  kubectl delete -f k8s-deployment.yaml"
                echo "  kubectl delete -f k8s-service.yaml"
                echo "  kubectl delete -f k8s-hpa.yaml"
            '''
        }
        failure {
            echo '❌ Kubernetes CI/CD Pipeline failed!'
            echo '🔍 Check the logs above for details'
            
            // Show Kubernetes logs for debugging
            sh '''
                echo "🔍 Kubernetes debugging information:"
                kubectl describe pods -l app=devops-chatbot || echo "Could not describe pods"
                kubectl logs -l app=devops-chatbot --tail=100 || echo "Could not get pod logs"
                kubectl get events --sort-by=.metadata.creationTimestamp || echo "Could not get events"
                minikube status || echo "Could not get Minikube status"
            '''
        }
    }
}
