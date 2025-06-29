# DevOps Chatbot - Kubernetes CI/CD Pipeline

A FastAPI-based DevOps chatbot with robust CI/CD pipeline using Jenkins, Docker, and Kubernetes. **Now supports both local Minikube and AWS EC2 cloud deployments with automatic environment detection.**

## 🚀 New Features (Phase 4)

- **🌩️ AWS EC2 Auto-Detection**: Pipeline automatically detects AWS environment and provides correct access URLs
- **🔐 Security Group Management**: Automated security group configuration guidance for AWS deployments  
- **🌍 Multi-Environment Support**: Single pipeline works for both local and cloud deployments
- **📡 Public/Private Access**: Automatic configuration of both public and private access URLs for AWS EC2
- **🧪 Enhanced Testing**: Comprehensive connectivity tests for cloud environments
- **📋 Detailed Monitoring**: Real-time deployment status and health checks

## 🏗️ Quick Deployment

### For AWS EC2 (Recommended)
1. Run Jenkins pipeline on AWS EC2 instance
2. Pipeline detects AWS environment automatically  
3. Provides public access URL: `http://your-public-ip:nodeport`
4. Includes security group configuration guidance

### For Local Development
1. Run Jenkins pipeline on local machine with Minikube
2. Pipeline detects local environment automatically
3. Provides local access URL: `http://minikube-ip:nodeport`

## 📖 Documentation

- **[AWS EC2 Deployment Guide](./AWS_EC2_DEPLOYMENT.md)** - Complete AWS deployment instructions
- **[Persistent Deployment Guide](./PERSISTENT_DEPLOYMENT.md)** - Management and monitoring
- **[Jenkins Configuration](./Jenkinsfile)** - Automated CI/CD pipeline

---

# Original Manual Deployment Guide

## Step 1: Launch an Ubuntu EC2 Instance

1. **Log in to AWS Console:**  
   Open the AWS Management Console and navigate to the EC2 service.
2. **Launch an Instance:**  
   - Click on **Launch Instances**.
   - Select an **Ubuntu Server (e.g., Ubuntu 22.04 LTS)** as the AMI.
   - Choose an instance type (e.g., `t2.micro`).
3. **Configure Security Group:**  
   Allow inbound traffic on port **22 (SSH)** and any other ports required.
4. **Launch & Key Pair:**  
   Launch the instance and download the associated SSH key pair.

*Once your Ubuntu EC2 instance is running, proceed to the next step.*

---

## Step 2: SSH into Your EC2 Instance and Clone Your Repository

1. **Open a Terminal on Your Local Machine.**
2. **SSH into Your Instance:**  
   Replace `mykey.pem` and the host with your actual key file and EC2 public DNS.
   ```bash
   chmod 400 mykey.pem
   ssh -i mykey.pem ubuntu@ec2-xx-xx-xx-xx.compute-1.amazonaws.com
   ```
3. **Update and Install Dependencies:**  
   ```bash
   sudo apt-get update && sudo apt-get upgrade -y
   sudo apt-get install -y python3 python3-pip git
   ```
4. **Clone Your Repository:**  
   ```bash
   git clone https://github.com/AhmadMughal-DS/final_chatbot_for_devops
   ```

*After cloning, continue with the next steps.*

---

## Step 3: Set Up a Python Virtual Environment and Test Your App

1. **Navigate to Your Repository Folder:**  
   ```bash
   cd <YOUR_REPO_FOLDER>
   ```
2. **Create and Activate a Virtual Environment:**  
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```
3. **Install Dependencies:**
   - If using a `requirements.txt` file:
     ```bash
     pip install -r requirements.txt
     ```
   - Otherwise, install manually:
     ```bash
     pip install fastapi uvicorn
     ```
4. **Test-run Your App:**  
   Run the app on port 8000.
   ```bash
   uvicorn main:app --host 0.0.0.0 --port 8000
   ```
5. **Verify in the Browser:**  
   Open your browser and navigate to `http://<EC2_PUBLIC_IP>:8000` to see your app running.

*Press Ctrl+C to stop the server after verification.*

---

## Step 4: Run the FastAPI App in the Background

1. **Run with nohup:**  
   While still in your project folder and with the virtual environment activated, run:
   ```bash
   nohup uvicorn main:app --host 0.0.0.0 --port 8000 &
   ```
   You should see a message like `[1] 12345` indicating the server is running in the background.
2. **Check Logs (Optional):**  
   To monitor log output:
   ```bash
   tail -f nohup.out
   ```

*Your application will keep running even if you disconnect from the SSH session.*

---

# DevOps Chatbot - Phase 4 (Kubernetes Deployment)

Welcome to the Kubernetes deployment guide for the DevOps Chatbot. This project includes Docker containerization, CI/CD pipeline with Jenkins, and Kubernetes deployment with HPA.

## 🏗️ Project Structure

```
final_chatbot_for_devops_phase_4/
├── backend/                          # FastAPI backend application
├── frontend/                         # HTML/CSS/JS frontend
├── tests/                           # Test files
│   └── test_frontend_chat_headless.py # Selenium headless tests
├── scripts/                         # Deployment and utility scripts
│   ├── run_frontend_test.sh         # Frontend test runner
│   ├── deploy_k8s.sh               # Kubernetes deployment script
│   └── cleanup_k8s.sh              # Kubernetes cleanup script
├── k8s-pvc.yaml                    # Kubernetes PersistentVolumeClaims
├── k8s-deployment.yaml             # Kubernetes Deployment
├── k8s-service.yaml                # Kubernetes Services
├── k8s-hpa.yaml                    # Horizontal Pod Autoscaler
├── docker-compose.yml              # Docker Compose configuration
├── Dockerfile                      # Docker container definition
├── Jenkinsfile                     # CI/CD pipeline configuration
└── requirements.txt                # Python dependencies
```

## 🚀 Quick Start (Kubernetes on Minikube)

### Prerequisites
- AWS EC2 t2.large instance
- Minikube installed and running
- kubectl configured
- Docker installed

### Deploy to Kubernetes
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Deploy to Kubernetes
./scripts/deploy_k8s.sh

# Access the application
minikube service devops-chatbot-loadbalancer --url
```

### Cleanup
```bash
./scripts/cleanup_k8s.sh
```

---

# DevOps Chatbot - Kubernetes CI/CD Pipeline

A FastAPI-based DevOps chatbot with robust CI/CD pipeline using Jenkins, Docker, and Kubernetes. Supports both local Minikube and AWS EC2 cloud deployments with automatic environment detection.

## 🚀 Features

- **FastAPI-based chatbot** with MongoDB integration
- **Kubernetes deployment** with auto-scaling (HPA)
- **Jenkins CI/CD pipeline** with automatic environment detection
- **Multi-environment support**: Local Minikube and AWS EC2
- **Persistent deployment** - no automatic teardown
- **Health checks** and automatic restarts
- **Security group management** for AWS deployments
- **Comprehensive testing suite**

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Jenkins       │    │     Docker       │    │   Kubernetes    │
│   Pipeline      │───▶│   Build & Push   │───▶│   Deployment    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                                               │
         └───────────────────────────────────────────────┘
                         Testing & Verification
```

## 📦 Deployment Options

### 🖥️ Local Minikube Deployment
- Automatic Minikube cluster management
- Local Docker registry integration
- Development and testing environment

### 🌩️ AWS EC2 Deployment  
- Automatic AWS environment detection
- Public/Private IP access URLs
- Security group configuration guidance
- Production-ready deployment

## 🚀 Quick Start

### Prerequisites
- Docker installed and running
- Kubernetes (Minikube for local, any cluster for cloud)
- Jenkins with necessary plugins
- Python 3.8+ (for local development)

### 1. Clone Repository
```bash
git clone <your-repo-url>
cd final_chatbot_for_devops_phase_4
```

### 2. Deploy via Jenkins
1. Configure Jenkins with this repository
2. Run the pipeline - it will automatically:
   - Detect your environment (Local/AWS)
   - Build and push Docker images
   - Deploy to Kubernetes
   - Configure auto-scaling
   - Provide access URLs

### 3. Access Your Application
- **Local**: `http://minikube-ip:nodeport`
- **AWS EC2**: `http://public-ip:nodeport`

## 📋 Environment-Specific Guides

### 🖥️ Local Development
See [Local Development Guide](./LOCAL_DEVELOPMENT.md)

### 🌩️ AWS EC2 Deployment
See [AWS EC2 Deployment Guide](./AWS_EC2_DEPLOYMENT.md)

### 🔧 Jenkins Configuration
See [Jenkins Setup Guide](./JENKINS_SETUP.md)

## 🛠️ Manual Management

### Check Deployment Status
```bash
./scripts/check_deployment_status.sh
```

### Test AWS Security Groups
```bash
./scripts/check_aws_security_group.sh
```

### Quick AWS Connectivity Test
```bash
./scripts/quick_aws_test.sh
```

### Stop Application
```bash
./scripts/cleanup_k8s_manual.sh
```

## 🧪 Testing

### Run All Tests
```bash
./scripts/run_tests.sh
```

### Individual Test Categories
```bash
# Backend API tests
python tests/test_chatbot.py

# Kubernetes connectivity tests  
python tests/test_k8s_connectivity.py

# Frontend tests
python tests/test_frontend_chat.py
```

## 📊 Monitoring & Scaling

### View Pod Status
```bash
kubectl get pods -l app=devops-chatbot
```

### Check Auto-scaling
```bash
kubectl get hpa devops-chatbot-hpa
```

### View Logs
```bash
kubectl logs -l app=devops-chatbot --tail=50
```

### Manual Scaling
```bash
kubectl scale deployment devops-chatbot-deployment --replicas=3
```

## 🔧 Configuration Files

| File | Purpose |
|------|---------|
| `Jenkinsfile` | CI/CD pipeline with environment detection |
| `Dockerfile` | Container image configuration |
| `k8s-*.yaml` | Kubernetes deployment manifests |
| `docker-compose.yml` | Local development environment |
| `requirements.txt` | Python dependencies |

## 🚨 Troubleshooting

### Common Issues

1. **Application not accessible externally (AWS)**
   - Check security group configuration
   - Run `./scripts/check_aws_security_group.sh`

2. **Minikube issues**
   - Pipeline includes automatic cluster recovery
   - Check `minikube status`

3. **Build failures**
   - Check Jenkins logs
   - Verify Docker daemon is running

4. **Pod not starting**
   - Check pod logs: `kubectl logs -l app=devops-chatbot`
   - Verify resource limits in k8s manifests

### Debug Commands
```bash
# Check all resources
kubectl get all -l app=devops-chatbot

# Describe deployment
kubectl describe deployment devops-chatbot-deployment

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp

# Test connectivity
curl http://localhost:nodeport
```

## 📈 Performance & Scaling

- **Auto-scaling**: Configured via HPA (2-10 replicas)
- **Resource limits**: CPU and memory limits set
- **Health checks**: Liveness and readiness probes
- **Graceful shutdown**: Proper termination handling

## 🔐 Security

- **Security groups**: Automated AWS configuration
- **Container security**: Non-root user in containers
- **Network policies**: Kubernetes network isolation
- **Secret management**: Kubernetes secrets for sensitive data

## 📚 Documentation

- [AWS EC2 Deployment Guide](./AWS_EC2_DEPLOYMENT.md)
- [Persistent Deployment Guide](./PERSISTENT_DEPLOYMENT.md)
- [Kubernetes Troubleshooting](./KUBERNETES_DEPLOYMENT.md)
- [API Server Troubleshooting](./API_SERVER_TROUBLESHOOTING.md)
- [Minikube Troubleshooting](./MINIKUBE_TROUBLESHOOTING.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Support

If you encounter issues:
1. Check the relevant troubleshooting guide
2. Review Jenkins build logs
3. Run diagnostic scripts in `./scripts/`
4. Check Kubernetes events and logs

---

# Original Ubuntu EC2 Setup (Alternative Manual Method)

*Note: The Jenkins pipeline automates most of these steps, but they're included for reference.*

## Step 1: Launch an Ubuntu EC2 Instance

1. **Log in to AWS Console:**  
   Open the AWS Management Console and navigate to the EC2 service.
2. **Launch an Instance:**  
   - Click on **Launch Instances**.
   - Select an **Ubuntu Server (e.g., Ubuntu 22.04 LTS)** as the AMI.
   - Choose an instance type (e.g., `t2.micro`).
3. **Configure Security Group:**  
   Allow inbound traffic on port **22 (SSH)** and any other ports required.
4. **Launch & Key Pair:**  
   Launch the instance and download the associated SSH key pair.

*Once your Ubuntu EC2 instance is running, proceed to the next step.*

---

## Step 2: SSH into Your EC2 Instance and Clone Your Repository

1. **Open a Terminal on Your Local Machine.**
2. **SSH into Your Instance:**  
   Replace `mykey.pem` and the host with your actual key file and EC2 public DNS.
   ```bash
   chmod 400 mykey.pem
   ssh -i mykey.pem ubuntu@ec2-xx-xx-xx-xx.compute-1.amazonaws.com
   ```
3. **Update and Install Dependencies:**  
   ```bash
   sudo apt-get update && sudo apt-get upgrade -y
   sudo apt-get install -y python3 python3-pip git
   ```
4. **Clone Your Repository:**  
   ```bash
   git clone https://github.com/AhmadMughal-DS/final_chatbot_for_devops
   ```

*After cloning, continue with the next steps.*

---

## Step 3: Set Up a Python Virtual Environment and Test Your App

1. **Navigate to Your Repository Folder:**  
   ```bash
   cd <YOUR_REPO_FOLDER>
   ```
2. **Create and Activate a Virtual Environment:**  
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```
3. **Install Dependencies:**
   - If using a `requirements.txt` file:
     ```bash
     pip install -r requirements.txt
     ```
   - Otherwise, install manually:
     ```bash
     pip install fastapi uvicorn
     ```
4. **Test-run Your App:**  
   Run the app on port 8000.
   ```bash
   uvicorn main:app --host 0.0.0.0 --port 8000
   ```
5. **Verify in the Browser:**  
   Open your browser and navigate to `http://<EC2_PUBLIC_IP>:8000` to see your app running.

*Press Ctrl+C to stop the server after verification.*

---

## Step 4: Run the FastAPI App in the Background

1. **Run with nohup:**  
   While still in your project folder and with the virtual environment activated, run:
   ```bash
   nohup uvicorn main:app --host 0.0.0.0 --port 8000 &
   ```
   You should see a message like `[1] 12345` indicating the server is running in the background.
2. **Check Logs (Optional):**  
   To monitor log output:
   ```bash
   tail -f nohup.out
   ```

*Your application will keep running even if you disconnect from the SSH session.*

---

# DevOps Chatbot - Phase 4 (Kubernetes Deployment)

Welcome to the Kubernetes deployment guide for the DevOps Chatbot. This project includes Docker containerization, CI/CD pipeline with Jenkins, and Kubernetes deployment with HPA.

## 🏗️ Project Structure

```
final_chatbot_for_devops_phase_4/
├── backend/                          # FastAPI backend application
├── frontend/                         # HTML/CSS/JS frontend
├── tests/                           # Test files
│   └── test_frontend_chat_headless.py # Selenium headless tests
├── scripts/                         # Deployment and utility scripts
│   ├── run_frontend_test.sh         # Frontend test runner
│   ├── deploy_k8s.sh               # Kubernetes deployment script
│   └── cleanup_k8s.sh              # Kubernetes cleanup script
├── k8s-pvc.yaml                    # Kubernetes PersistentVolumeClaims
├── k8s-deployment.yaml             # Kubernetes Deployment
├── k8s-service.yaml                # Kubernetes Services
├── k8s-hpa.yaml                    # Horizontal Pod Autoscaler
├── docker-compose.yml              # Docker Compose configuration
├── Dockerfile                      # Docker container definition
├── Jenkinsfile                     # CI/CD pipeline configuration
└── requirements.txt                # Python dependencies
```

## 🚀 Quick Start (Kubernetes on Minikube)

### Prerequisites
- AWS EC2 t2.large instance
- Minikube installed and running
- kubectl configured
- Docker installed

### Deploy to Kubernetes
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Deploy to Kubernetes
./scripts/deploy_k8s.sh

# Access the application
minikube service devops-chatbot-loadbalancer --url
```

### Cleanup
```bash
./scripts/cleanup_k8s.sh
```

---

# DevOps Chatbot - Kubernetes CI/CD Pipeline

A FastAPI-based DevOps chatbot with robust CI/CD pipeline using Jenkins, Docker, and Kubernetes. Supports both local Minikube and AWS EC2 cloud deployments with automatic environment detection.

## 🚀 Features

- **FastAPI-based chatbot** with MongoDB integration
- **Kubernetes deployment** with auto-scaling (HPA)
- **Jenkins CI/CD pipeline** with automatic environment detection
- **Multi-environment support**: Local Minikube and AWS EC2
- **Persistent deployment** - no automatic teardown
- **Health checks** and automatic restarts
- **Security group management** for AWS deployments
- **Comprehensive testing suite**

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Jenkins       │    │     Docker       │    │   Kubernetes    │
│   Pipeline      │───▶│   Build & Push   │───▶│   Deployment    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                                               │
         └───────────────────────────────────────────────┘
                         Testing & Verification
```

## 📦 Deployment Options

### 🖥️ Local Minikube Deployment
- Automatic Minikube cluster management
- Local Docker registry integration
- Development and testing environment

### 🌩️ AWS EC2 Deployment  
- Automatic AWS environment detection
- Public/Private IP access URLs
- Security group configuration guidance
- Production-ready deployment

## 🚀 Quick Start

### Prerequisites
- Docker installed and running
- Kubernetes (Minikube for local, any cluster for cloud)
- Jenkins with necessary plugins
- Python 3.8+ (for local development)

### 1. Clone Repository
```bash
git clone <your-repo-url>
cd final_chatbot_for_devops_phase_4
```

### 2. Deploy via Jenkins
1. Configure Jenkins with this repository
2. Run the pipeline - it will automatically:
   - Detect your environment (Local/AWS)
   - Build and push Docker images
   - Deploy to Kubernetes
   - Configure auto-scaling
   - Provide access URLs

### 3. Access Your Application
- **Local**: `http://minikube-ip:nodeport`
- **AWS EC2**: `http://public-ip:nodeport`

## 📋 Environment-Specific Guides

### 🖥️ Local Development
See [Local Development Guide](./LOCAL_DEVELOPMENT.md)

### 🌩️ AWS EC2 Deployment
See [AWS EC2 Deployment Guide](./AWS_EC2_DEPLOYMENT.md)

### 🔧 Jenkins Configuration
See [Jenkins Setup Guide](./JENKINS_SETUP.md)

## 🛠️ Manual Management

### Check Deployment Status
```bash
./scripts/check_deployment_status.sh
```

### Test AWS Security Groups
```bash
./scripts/check_aws_security_group.sh
```

### Quick AWS Connectivity Test
```bash
./scripts/quick_aws_test.sh
```

### Stop Application
```bash
./scripts/cleanup_k8s_manual.sh
```

## 🧪 Testing

### Run All Tests
```bash
./scripts/run_tests.sh
```

### Individual Test Categories
```bash
# Backend API tests
python tests/test_chatbot.py

# Kubernetes connectivity tests  
python tests/test_k8s_connectivity.py

# Frontend tests
python tests/test_frontend_chat.py
```

## 📊 Monitoring & Scaling

### View Pod Status
```bash
kubectl get pods -l app=devops-chatbot
```

### Check Auto-scaling
```bash
kubectl get hpa devops-chatbot-hpa
```

### View Logs
```bash
kubectl logs -l app=devops-chatbot --tail=50
```

### Manual Scaling
```bash
kubectl scale deployment devops-chatbot-deployment --replicas=3
```

## 🔧 Configuration Files

| File | Purpose |
|------|---------|
| `Jenkinsfile` | CI/CD pipeline with environment detection |
| `Dockerfile` | Container image configuration |
| `k8s-*.yaml` | Kubernetes deployment manifests |
| `docker-compose.yml` | Local development environment |
| `requirements.txt` | Python dependencies |

## 🚨 Troubleshooting

### Common Issues

1. **Application not accessible externally (AWS)**
   - Check security group configuration
   - Run `./scripts/check_aws_security_group.sh`

2. **Minikube issues**
   - Pipeline includes automatic cluster recovery
   - Check `minikube status`

3. **Build failures**
   - Check Jenkins logs
   - Verify Docker daemon is running

4. **Pod not starting**
   - Check pod logs: `kubectl logs -l app=devops-chatbot`
   - Verify resource limits in k8s manifests

### Debug Commands
```bash
# Check all resources
kubectl get all -l app=devops-chatbot

# Describe deployment
kubectl describe deployment devops-chatbot-deployment

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp

# Test connectivity
curl http://localhost:nodeport
```

## 📈 Performance & Scaling

- **Auto-scaling**: Configured via HPA (2-10 replicas)
- **Resource limits**: CPU and memory limits set
- **Health checks**: Liveness and readiness probes
- **Graceful shutdown**: Proper termination handling

## 🔐 Security

- **Security groups**: Automated AWS configuration
- **Container security**: Non-root user in containers
- **Network policies**: Kubernetes network isolation
- **Secret management**: Kubernetes secrets for sensitive data

## 📚 Documentation

- [AWS EC2 Deployment Guide](./AWS_EC2_DEPLOYMENT.md)
- [Persistent Deployment Guide](./PERSISTENT_DEPLOYMENT.md)
- [Kubernetes Troubleshooting](./KUBERNETES_DEPLOYMENT.md)
- [API Server Troubleshooting](./API_SERVER_TROUBLESHOOTING.md)
- [Minikube Troubleshooting](./MINIKUBE_TROUBLESHOOTING.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Support

If you encounter issues:
1. Check the relevant troubleshooting guide
2. Review Jenkins build logs
3. Run diagnostic scripts in `./scripts/`
4. Check Kubernetes events and logs

---

# Original Ubuntu EC2 Setup (Alternative Manual Method)

*Note: The Jenkins pipeline automates most of these steps, but they're included for reference.*

## Step 1: Launch an Ubuntu EC2 Instance

1. **Log in to AWS Console:**  
   Open the AWS Management Console and navigate to the EC2 service.
2. **Launch an Instance:**  
   - Click on **Launch Instances**.
   - Select an **Ubuntu Server (e.g., Ubuntu 22.04 LTS)** as the AMI.
   - Choose an instance type (e.g., `t2.micro`).
3. **Configure Security Group:**  
   Allow inbound traffic on port **22 (SSH)** and any other ports required.
4. **Launch & Key Pair:**  
   Launch the instance and download the associated SSH key pair.

*Once your Ubuntu EC2 instance is running, proceed to the next step.*

---

## Step 2: SSH into Your EC2 Instance and Clone Your Repository

1. **Open a Terminal on Your Local Machine.**
2. **SSH into Your Instance:**  
   Replace `mykey.pem` and the host with your actual key file and EC2 public DNS.
   ```bash
   chmod 400 mykey.pem
   ssh -i mykey.pem ubuntu@ec2-xx-xx-xx-xx.compute-1.amazonaws.com
   ```
3. **Update and Install Dependencies:**  
   ```bash
   sudo apt-get update && sudo apt-get upgrade -y
   sudo apt-get install -y python3 python3-pip git
   ```
4. **Clone Your Repository:**  
   ```bash
   git clone https://github.com/AhmadMughal-DS/final_chatbot_for_devops
   ```

*After cloning, continue with the next steps.*

---

## Step 3: Set Up a Python Virtual Environment and Test Your App

1. **Navigate to Your Repository Folder:**  
   ```bash
   cd <YOUR_REPO_FOLDER>
   ```
2. **Create and Activate a Virtual Environment:**  
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```
3. **Install Dependencies:**
   - If using a `requirements.txt` file:
     ```bash
     pip install -r requirements.txt
     ```
   - Otherwise, install manually:
     ```bash
     pip install fastapi uvicorn
     ```
4. **Test-run Your App:**  
   Run the app on port 8000.
   ```bash
   uvicorn main:app --host 0.0.0.0 --port 8000
   ```
5. **Verify in the Browser:**  
   Open your browser and navigate to `http://<EC2_PUBLIC_IP>:8000` to see your app running.

*Press Ctrl+C to stop the server after verification.*

---

## Step 4: Run the FastAPI App in the Background

1. **Run with nohup:**  
   While still in your project folder and with the virtual environment activated, run:
   ```bash
   nohup uvicorn main:app --host 0.0.0.0 --port 8000 &
   ```
   You should see a message like `[1] 12345` indicating the server is running in the background.
2. **Check Logs (Optional):**  
   To monitor log output:
   ```bash
   tail -f nohup.out
   ```

*Your application will keep running even if you disconnect from the SSH session.*

---

# DevOps Chatbot - Phase 4 (Kubernetes Deployment)

Welcome to the Kubernetes deployment guide for the DevOps Chatbot. This project includes Docker containerization, CI/CD pipeline with Jenkins, and Kubernetes deployment with HPA.

## 🏗️ Project Structure

```
final_chatbot_for_devops_phase_4/
├── backend/                          # FastAPI backend application
├── frontend/                         # HTML/CSS/JS frontend
├── tests/                           # Test files
│   └── test_frontend_chat_headless.py # Selenium headless tests
├── scripts/                         # Deployment and utility scripts
│   ├── run_frontend_test.sh         # Frontend test runner
│   ├── deploy_k8s.sh               # Kubernetes deployment script
│   └── cleanup_k8s.sh              # Kubernetes cleanup script
├── k8s-pvc.yaml                    # Kubernetes PersistentVolumeClaims
├── k8s-deployment.yaml             # Kubernetes Deployment
├── k8s-service.yaml                # Kubernetes Services
├── k8s-hpa.yaml                    # Horizontal Pod Autoscaler
├── docker-compose.yml              # Docker Compose configuration
├── Dockerfile                      # Docker container definition
├── Jenkinsfile                     # CI/CD pipeline configuration
└── requirements.txt                # Python dependencies
```

## 🚀 Quick Start (Kubernetes on Minikube)

### Prerequisites
- AWS EC2 t2.large instance
- Minikube installed and running
- kubectl configured
- Docker installed

### Deploy to Kubernetes
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Deploy to Kubernetes
./scripts/deploy_k8s.sh

# Access the application
minikube service devops-chatbot-loadbalancer --url
```

### Cleanup
```bash
./scripts/cleanup_k8s.sh
```

---

# DevOps Chatbot - Kubernetes CI/CD Pipeline

A FastAPI-based DevOps chatbot with robust CI/CD pipeline using Jenkins, Docker, and Kubernetes. Supports both local Minikube and AWS EC2 cloud deployments with automatic environment detection.

## 🚀 Features

- **FastAPI-based chatbot** with MongoDB integration
- **Kubernetes deployment** with auto-scaling (HPA)
- **Jenkins CI/CD pipeline** with automatic environment detection
- **Multi-environment support**: Local Minikube and AWS EC2
- **Persistent deployment** - no automatic teardown
- **Health checks** and automatic restarts
- **Security group management** for AWS deployments
- **Comprehensive testing suite**

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Jenkins       │    │     Docker       │    │   Kubernetes    │
│   Pipeline      │───▶│   Build & Push   │───▶│   Deployment    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                                               │
         └───────────────────────────────────────────────┘
                         Testing & Verification
```

## 📦 Deployment Options

### 🖥️ Local Minikube Deployment
- Automatic Minikube cluster management
- Local Docker registry integration
- Development and testing environment

### 🌩️ AWS EC2 Deployment  
- Automatic AWS environment detection
- Public/Private IP access URLs
- Security group configuration guidance
- Production-ready deployment

## 🚀 Quick Start

### Prerequisites
- Docker installed and running
- Kubernetes (Minikube for local, any cluster for cloud)
- Jenkins with necessary plugins
- Python 3.8+ (for local development)

### 1. Clone Repository
```bash
git clone <your-repo-url>
cd final_chatbot_for_devops_phase_4
```

### 2. Deploy via Jenkins
1. Configure Jenkins with this repository
2. Run the pipeline - it will automatically:
   - Detect your environment (Local/AWS)
   - Build and push Docker images
   - Deploy to Kubernetes
   - Configure auto-scaling
   - Provide access URLs

### 3. Access Your Application
- **Local**: `http://minikube-ip:nodeport`
- **AWS EC2**: `http://public-ip:nodeport`

## 📋 Environment-Specific Guides

### 🖥️ Local Development
See [Local Development Guide](./LOCAL_DEVELOPMENT.md)

### 🌩️ AWS EC2 Deployment
See [AWS EC2 Deployment Guide](./AWS_EC2_DEPLOYMENT.md)

### 🔧 Jenkins Configuration
See [Jenkins Setup Guide](./JENKINS_SETUP.md)

## 🛠️ Manual Management

### Check Deployment Status
```bash
./scripts/check_deployment_status.sh
```

### Test AWS Security Groups
```bash
./scripts/check_aws_security_group.sh
```

### Quick AWS Connectivity Test
```bash
./scripts/quick_aws_test.sh
```

### Stop Application
```bash
./scripts/cleanup_k8s_manual.sh
```

## 🧪 Testing

### Run All Tests
```bash
./scripts/run_tests.sh
```

### Individual Test Categories
```bash
# Backend API tests
python tests/test_chatbot.py

# Kubernetes connectivity tests  
python tests/test_k8s_connectivity.py

# Frontend tests
python tests/test_frontend_chat.py
```

## 📊 Monitoring & Scaling

### View Pod Status
```bash
kubectl get pods -l app=devops-chatbot
```

### Check Auto-scaling
```bash
kubectl get hpa devops-chatbot-hpa
```

### View Logs
```bash
kubectl logs -l app=devops-chatbot --tail=50
```

### Manual Scaling
```bash
kubectl scale deployment devops-chatbot-deployment --replicas=3
```

## 🔧 Configuration Files

| File | Purpose |
|------|---------|
| `Jenkinsfile` | CI/CD pipeline with environment detection |
| `Dockerfile` | Container image configuration |
| `k8s-*.yaml` | Kubernetes deployment manifests |
| `docker-compose.yml` | Local development environment |
| `requirements.txt` | Python dependencies |

## 🚨 Troubleshooting

### Common Issues

1. **Application not accessible externally (AWS)**
   - Check security group configuration
   - Run `./scripts/check_aws_security_group.sh`

2. **Minikube issues**
   - Pipeline includes automatic cluster recovery
   - Check `minikube status`

3. **Build failures**
   - Check Jenkins logs
   - Verify Docker daemon is running

4. **Pod not starting**
   - Check pod logs: `kubectl logs -l app=devops-chatbot`
   - Verify resource limits in k8s manifests

### Debug Commands
```bash
# Check all resources
kubectl get all -l app=devops-chatbot

# Describe deployment
kubectl describe deployment devops-chatbot-deployment

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp

# Test connectivity
curl http://localhost:nodeport
```

## 📈 Performance & Scaling

- **Auto-scaling**: Configured via HPA (2-10 replicas)
- **Resource limits**: CPU and memory limits set
- **Health checks**: Liveness and readiness probes
- **Graceful shutdown**: Proper termination handling

## 🔐 Security

- **Security groups**: Automated AWS configuration
- **Container security**: Non-root user in containers
- **Network policies**: Kubernetes network isolation
- **Secret management**: Kubernetes secrets for sensitive data

## 📚 Documentation

- [AWS EC2 Deployment Guide](./AWS_EC2_DEPLOYMENT.md)
- [Persistent Deployment Guide](./PERSISTENT_DEPLOYMENT.md)
- [Kubernetes Troubleshooting](./KUBERNETES_DEPLOYMENT.md)
- [API Server Troubleshooting](./API_SERVER_TROUBLESHOOTING.md)
- [Minikube Troubleshooting](./MINIKUBE_TROUBLESHOOTING.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Support

If you encounter issues:
1. Check the relevant troubleshooting guide
2. Review Jenkins build logs
3. Run diagnostic scripts in `./scripts/`
4. Check Kubernetes events and logs

---

# Original Ubuntu EC2 Setup (Alternative Manual Method)

*Note: The Jenkins pipeline automates most of these steps, but they're included for reference.*

## Step 1: Launch an Ubuntu EC2 Instance

1. **Log in to AWS Console:**  
   Open the AWS Management Console and navigate to the EC2 service.
2. **Launch an Instance:**  
   - Click on **Launch Instances**.
   - Select an **Ubuntu Server (e.g., Ubuntu 22.04 LTS)** as the AMI.
   - Choose an instance type (e.g., `t2.micro`).
3. **Configure Security Group:**  
   Allow inbound traffic on port **22 (SSH)** and any other ports required.
4. **Launch & Key Pair:**  
   Launch the instance and download the associated SSH key pair.

*Once your Ubuntu EC2 instance is running, proceed to the next step.*

---

## Step 2: SSH into Your EC2 Instance and Clone Your Repository

1. **Open a Terminal on Your Local Machine.**
2. **SSH into Your Instance:**  
   Replace `mykey.pem` and the host with your actual key file and EC2 public DNS.
   ```bash
   chmod 400 mykey.pem
   ssh -i mykey.pem ubuntu@ec2-xx-xx-xx-xx.compute-1.amazonaws.com
   ```
3. **Update and Install Dependencies:**  
   ```bash
   sudo apt-get update && sudo apt-get upgrade -y
   sudo apt-get install -y python3 python3-pip git
   ```
4. **Clone Your Repository:**  
   ```bash
   git clone https://github.com/AhmadMughal-DS/final_chatbot_for_devops
   ```

*After cloning, continue with the next steps.*

---

## Step 3: Set Up a Python Virtual Environment and Test Your App

1. **Navigate to Your Repository Folder:**  
   ```bash
   cd <YOUR_REPO_FOLDER>
   ```
2. **Create and Activate a Virtual Environment:**  
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```
3. **Install Dependencies:**
   - If using a `requirements.txt` file:
     ```bash
     pip install -r requirements.txt
     ```
   - Otherwise, install manually:
     ```bash
     pip install fastapi uvicorn
     ```
4. **Test-run Your App:**  
   Run the app on port 8000.
   ```bash
   uvicorn main:app --host 0.0.0.0 --port 8000
   ```
5. **Verify in the Browser:**  
   Open your browser and navigate to `http://<EC2_PUBLIC_IP>:8000` to see your app running.

*Press Ctrl+C to stop the server after verification.*

---

## Step 4: Run the FastAPI App in the Background

1. **Run with nohup:**  
   While still in your project folder and with the virtual environment activated, run:
   ```bash
   nohup uvicorn main:app --host 0.0.0.0 --port 8000 &
   ```
   You should see a message like `[1] 12345` indicating the server is running in the background.
2. **Check Logs (Optional):**  
   To monitor log output:
   ```bash
   tail -f nohup.out
   ```

*Your application will keep running even if you disconnect from the SSH session.*

---

# DevOps Chatbot - Phase 4 (Kubernetes Deployment)

Welcome to the Kubernetes deployment guide for the DevOps Chatbot. This project includes Docker containerization, CI/CD pipeline with Jenkins, and Kubernetes deployment with HPA.

## 🏗️ Project Structure

```
final_chatbot_for_devops_phase_4/
├── backend/                          # FastAPI backend application
├── frontend/                         # HTML/CSS/JS frontend
├── tests/                           # Test files
│   └── test_frontend_chat_headless.py # Selenium headless tests
├── scripts/                         # Deployment and utility scripts
│   ├── run_frontend_test.sh         # Frontend test runner
│   ├── deploy_k8s.sh               # Kubernetes deployment script
│   └── cleanup_k8s.sh              # Kubernetes cleanup script
├── k8s-pvc.yaml                    # Kubernetes PersistentVolumeClaims
├── k8s-deployment.yaml             # Kubernetes Deployment
├── k8s-service.yaml                # Kubernetes Services
├── k8s-hpa.yaml                    # Horizontal Pod Autoscaler
├── docker-compose.yml              # Docker Compose configuration
├── Dockerfile                      # Docker container definition
├── Jenkinsfile                     # CI/CD pipeline configuration
└── requirements.txt                # Python dependencies
```

## 🚀 Quick Start (Kubernetes on Minikube)

### Prerequisites
- AWS EC2 t2.large instance
- Minikube installed and running
- kubectl configured
- Docker installed

### Deploy to Kubernetes
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Deploy to Kubernetes
./scripts/deploy_k8s.sh

# Access the application
minikube service devops-chatbot-loadbalancer --url
```

### Cleanup
```bash
./scripts/cleanup_k8s.sh
```

---

# DevOps Chatbot - Kubernetes CI/CD Pipeline

A FastAPI-based DevOps chatbot with robust CI/CD pipeline using Jenkins, Docker, and Kubernetes. Supports both local Minikube and AWS EC2 cloud deployments with automatic environment detection.

## 🚀 Features

- **FastAPI-based chatbot** with MongoDB integration
- **Kubernetes deployment** with auto-scaling (HPA)
- **Jenkins CI/CD pipeline** with automatic environment detection
- **Multi-environment support**: Local Minikube and AWS EC2
- **Persistent deployment** - no automatic teardown
- **Health checks** and automatic restarts
- **Security group management** for AWS deployments
- **Comprehensive testing suite**

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Jenkins       │    │     Docker       │    │   Kubernetes    │
│   Pipeline      │───▶│   Build & Push   │───▶│   Deployment    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                                               │
         └───────────────────────────────────────────────┘
                         Testing & Verification
```

## 📦 Deployment Options

### 🖥️ Local Minikube Deployment
- Automatic Minikube cluster management
- Local Docker registry integration
- Development and testing environment

### 🌩️ AWS EC2 Deployment  
- Automatic AWS environment detection
- Public/Private IP access URLs
- Security group configuration guidance
- Production-ready deployment

## 🚀 Quick Start

### Prerequisites
- Docker installed and running
- Kubernetes (Minikube for local, any cluster for cloud)
- Jenkins with necessary plugins
- Python 3.8+ (for local development)

### 1. Clone Repository
```bash
git clone <your-repo-url>
cd final_chatbot_for_devops_phase_4
```

### 2. Deploy via Jenkins
1. Configure Jenkins with this repository
2. Run the pipeline - it will automatically:
   - Detect your environment (Local/AWS)
   - Build and push Docker images
   - Deploy to Kubernetes
   - Configure auto-scaling
   - Provide access URLs

### 3. Access Your Application
- **Local**: `http://minikube-ip:nodeport`
- **AWS EC2**: `http://public-ip:nodeport`

## 📋 Environment-Specific Guides

### 🖥️ Local Development
See [Local Development Guide](./LOCAL_DEVELOPMENT.md)

### 🌩️ AWS EC2 Deployment
See [AWS EC2 Deployment Guide](./AWS_EC2_DEPLOYMENT.md)

### 🔧 Jenkins Configuration
See [Jenkins Setup Guide](./JENKINS_SETUP.md)

## 🛠️ Manual Management

### Check Deployment Status
```bash
./scripts/check_deployment_status.sh
```

### Test AWS Security Groups
```bash
./scripts/check_aws_security_group.sh
```

### Quick AWS Connectivity Test
```bash
./scripts/quick_aws_test.sh
```

### Stop Application
```bash
./scripts/cleanup_k8s_manual.sh
```

## 🧪 Testing

### Run All Tests
```bash
./scripts/run_tests.sh
```

### Individual Test Categories
```bash
# Backend API tests
python tests/test_chatbot.py

# Kubernetes connectivity tests  
python tests/test_k8s_connectivity.py

# Frontend tests
python tests/test_frontend_chat.py
```

## 📊 Monitoring & Scaling

### View Pod Status
```bash
kubectl get pods -l app=devops-chatbot
```

### Check Auto-scaling
```bash
kubectl get hpa devops-chatbot-hpa
```

### View Logs
```bash
kubectl logs -l app=devops-chatbot --tail=50
```

### Manual Scaling
```bash
kubectl scale deployment devops-chatbot-deployment --replicas=3
```

## 🔧 Configuration Files

| File | Purpose |
|------|---------|
| `Jenkinsfile` | CI/CD pipeline with environment detection |
| `Dockerfile` | Container image configuration |
| `k8s-*.yaml` | Kubernetes deployment manifests |
| `docker-compose.yml` | Local development environment |
| `requirements.txt` | Python dependencies |

## 🚨 Troubleshooting

### Common Issues

1. **Application not accessible externally (AWS)**
   - Check security group configuration
   - Run `./scripts/check_aws_security_group.sh`

2. **Minikube issues**
   - Pipeline includes automatic cluster recovery
   - Check `minikube status`

3. **Build failures**
   - Check Jenkins logs
   - Verify Docker daemon is running

4. **Pod not starting**
   - Check pod logs: `kubectl logs -l app=devops-chatbot`
   - Verify resource limits in k8s manifests

### Debug Commands
```bash
# Check all resources
kubectl get all -l app=devops-chatbot

# Describe deployment
kubectl describe deployment devops-chatbot-deployment

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp

# Test connectivity
curl http://localhost:nodeport
```

## 📈 Performance & Scaling

- **Auto-scaling**: Configured via HPA (2-10 replicas)
- **Resource limits**: CPU and memory limits set
- **Health checks**: Liveness and readiness probes
- **Graceful shutdown**: Proper termination handling

## 🔐 Security

- **Security groups**: Automated AWS configuration
- **Container security**: Non-root user in containers
- **Network policies**: Kubernetes network isolation
- **Secret management**: Kubernetes secrets for sensitive data

## 📚 Documentation

- [AWS EC2 Deployment Guide](./AWS_EC2_DEPLOYMENT.md)
- [Persistent Deployment Guide](./PERSISTENT_DEPLOYMENT.md)
- [Kubernetes Troubleshooting](./KUBERNETES_DEPLOYMENT.md)
- [API Server Troubleshooting](./API_SERVER_TROUBLESHOOTING.md)
- [Minikube Troubleshooting](./MINIKUBE_TROUBLESHOOTING.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Support

If you encounter issues:
1. Check the relevant troubleshooting guide
2. Review Jenkins build logs
3. Run diagnostic scripts in `./scripts/`
4. Check Kubernetes events and logs

---

# Original Ubuntu EC2 Setup (Alternative Manual Method)

*Note: The Jenkins pipeline automates most of these steps, but they're included for reference.*

## Step 1: Launch an Ubuntu EC2 Instance

1. **Log in to AWS Console:**  
   Open the AWS Management Console and navigate to the EC2 service.
2. **Launch an Instance:**  
   - Click on **Launch Instances**.
   - Select an **Ubuntu Server (e.g., Ubuntu 22.04 LTS)** as the AMI.
   - Choose an instance type (e.g., `t2.micro`).
3. **Configure Security Group:**  
   Allow inbound traffic on port **22 (SSH)** and any other ports required.
4. **Launch & Key Pair:**  
   Launch the instance and download the associated SSH key pair.

*Once your Ubuntu EC2 instance is running, proceed to the next step.*

---

## Step 2: SSH into Your EC2 Instance and Clone Your Repository

1. **Open a Terminal on Your Local Machine.**
2. **SSH into Your Instance:**  
   Replace `mykey.pem` and the host with your actual key file and EC2 public DNS.
   ```bash
   chmod 400 mykey.pem
   ssh -i mykey.pem ubuntu@ec2-xx-xx-xx-xx.compute-1.amazonaws.com
   ```
3. **Update and Install Dependencies:**  
   ```bash
   sudo apt-get update && sudo apt-get upgrade -y
   sudo apt-get install -y python3 python3-pip git
   ```
4. **Clone Your Repository:**  
   ```bash
   git clone https://github.com/AhmadMughal-DS/final_chatbot_for_devops
   ```

*After cloning, continue with the next steps.*

---

## Step 3: Set Up a Python Virtual Environment and Test Your App

1. **Navigate to Your Repository Folder:**  
   ```bash
   cd <YOUR_REPO_FOLDER>
   ```
2. **Create and Activate a Virtual Environment:**  
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```
3. **Install Dependencies:**
   - If using a `requirements.txt` file:
     ```bash
     pip install -r requirements.txt
     ```
   - Otherwise, install manually:
     ```bash
     pip install fastapi uvicorn
     ```
4. **Test-run Your App:**  
   Run the app on port 8000.
   ```bash
   uvicorn main:app --host 0.0.0.0 --port 8000
   ```
5. **Verify in the Browser:**  
   Open your browser and navigate to `http://<EC2_PUBLIC_IP>:8000` to see your app running.

*Press Ctrl+C to stop the server after verification.*

---

## Step 4: Run the FastAPI App in the Background

1. **Run with nohup:**  
   While still in your project folder and with the virtual environment activated, run:
   ```bash
   nohup uvicorn main:app --host 0.0.0.0 --port 8000 &
   ```
   You should see a message like `[1] 12345` indicating the server is running in the background.
2. **Check Logs (Optional):**  
   To monitor log output:
   ```bash
   tail -f nohup.out
   ```

*Your application will keep running even if you disconnect from the SSH session.*

---

# DevOps Chatbot - Phase 4 (Kubernetes Deployment)

Welcome to the Kubernetes deployment guide for the DevOps Chatbot. This project includes Docker containerization, CI/CD pipeline with Jenkins, and Kubernetes deployment with HPA.

## 🏗️ Project Structure

```
final_chatbot_for_devops_phase_4/
├── backend/                          # FastAPI backend application
├── frontend/                         # HTML/CSS/JS frontend
├── tests/                           # Test files
│   └── test_frontend_chat_headless.py # Selenium headless tests
├── scripts/                         # Deployment and utility scripts
│   ├── run_frontend_test.sh         # Frontend test runner
│   ├── deploy_k8s.sh               # Kubernetes deployment script
│   └── cleanup_k8s.sh              # Kubernetes cleanup script
├── k8s-pvc.yaml                    # Kubernetes PersistentVolumeClaims
├── k8s-deployment.yaml             # Kubernetes Deployment
├── k8s-service.yaml                # Kubernetes Services
├── k8s-hpa.yaml                    # Horizontal Pod Autoscaler
├── docker-compose.yml              # Docker Compose configuration
├── Dockerfile                      # Docker container definition
├── Jenkinsfile                     # CI/CD pipeline configuration
└── requirements.txt                # Python dependencies
```

## 🚀 Quick Start (Kubernetes on Minikube)

### Prerequisites
- AWS EC2 t2.large instance
- Minikube installed and running
- kubectl configured
- Docker installed

### Deploy to Kubernetes
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Deploy to Kubernetes
./scripts/deploy_k8s.sh

# Access the application
minikube service devops-chatbot-loadbalancer --url
```

### Cleanup
```bash
./scripts/cleanup_k8s.sh
```

---

# DevOps Chatbot - Kubernetes CI/CD Pipeline

A FastAPI-based DevOps chatbot with robust CI/CD pipeline using Jenkins, Docker, and Kubernetes. Supports both local Minikube and AWS EC2 cloud deployments with automatic environment detection.

## 🚀 Features

- **FastAPI-based chatbot** with MongoDB integration
- **Kubernetes deployment** with auto-scaling (HPA)
- **Jenkins CI/CD pipeline** with automatic environment detection
- **Multi-environment support**: Local Minikube and AWS EC2
- **Persistent deployment** - no automatic teardown
- **Health checks** and automatic restarts
- **Security group management** for AWS deployments
- **Comprehensive testing suite**

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Jenkins       │    │     Docker       │    │   Kubernetes    │
│   Pipeline      │───▶│   Build & Push   │───▶│   Deployment    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                                               │
         └───────────────────────────────────────────────┘
                         Testing & Verification
```

## 📦 Deployment Options

### 🖥️ Local Minikube Deployment
- Automatic Minikube cluster management
- Local Docker registry integration
- Development and testing environment

### 🌩️ AWS EC2 Deployment  
- Automatic AWS environment detection
- Public/Private IP access URLs
- Security group configuration guidance
- Production-ready deployment

## 🚀 Quick Start

### Prerequisites
- Docker installed and running
- Kubernetes (Minikube for local, any cluster for cloud)
- Jenkins with necessary plugins
- Python 3.8+ (for local development)

### 1. Clone Repository
```bash
git clone <your-repo-url>
cd final_chatbot_for_devops_phase_4
```

### 2. Deploy via Jenkins
1. Configure Jenkins with this repository
2. Run the pipeline - it will automatically:
   - Detect your environment (Local/AWS)
   - Build and push Docker images
   - Deploy to Kubernetes
   - Configure auto-scaling
   - Provide access URLs

### 3. Access Your Application
- **Local**: `http://minikube-ip:nodeport`
- **AWS EC2**: `http://public-ip:nodeport`

## 📋 Environment-Specific Guides

### 🖥️ Local Development
See [Local Development Guide](./LOCAL_DEVELOPMENT.md)

### 🌩️ AWS EC2 Deployment
See [AWS EC2 Deployment Guide](./AWS_EC2_DEPLOYMENT.md)

### 🔧 Jenkins Configuration
See [Jenkins Setup Guide](./JENKINS_SETUP.md)

## 🛠️ Manual Management

### Check Deployment Status
```bash
./scripts/check_deployment_status.sh
```

### Test AWS Security Groups
```bash
./scripts/check_aws_security_group.sh
```

### Quick AWS Connectivity Test
```bash
./scripts/quick_aws_test.sh
```

### Stop Application
```bash
./scripts/cleanup_k8s_manual.sh
```

## 🧪 Testing

### Run All Tests
```bash
./scripts/run_tests.sh
```

### Individual Test Categories
```bash
# Backend API tests
python tests/test_chatbot.py

# Kubernetes connectivity tests  
python tests/test_k8s_connectivity.py

# Frontend tests
python tests/test_frontend_chat.py
```

## 📊 Monitoring & Scaling

### View Pod Status
```bash
kubectl get pods -l app=devops-chatbot
```

### Check Auto-scaling
```bash
kubectl get hpa devops-chatbot-hpa
```

### View Logs
```bash
kubectl logs -l app=devops-chatbot --tail=50
```

### Manual Scaling
```bash
kubectl scale deployment devops-chatbot-deployment --replicas=3
```

## 🔧 Configuration Files

| File | Purpose |
|------|---------|
| `Jenkinsfile` | CI/CD pipeline with environment detection |
| `Dockerfile` | Container image configuration |
| `k8s-*.yaml` | Kubernetes deployment manifests |
| `docker-compose.yml` | Local development environment |
| `requirements.txt` | Python dependencies |

## 🚨 Troubleshooting

### Common Issues

1. **Application not accessible externally (AWS)**
   - Check security group configuration
   - Run `./scripts/check_aws_security_group.sh`

2. **Minikube issues**
   - Pipeline includes automatic cluster recovery
   - Check `minikube status`

3. **Build failures**
   - Check Jenkins logs
   - Verify Docker daemon is running

4. **Pod not starting**
   - Check pod logs: `kubectl logs -l app=devops-chatbot`
   - Verify resource limits in k8s manifests

### Debug Commands
```bash
# Check all resources
kubectl get all -l app=devops-chatbot

# Describe deployment
kubectl describe deployment devops-chatbot-deployment

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp

# Test connectivity
curl http://localhost:nodeport
```

## 📈 Performance & Scaling

- **Auto-scaling**: Configured via HPA (2-10 replicas)
- **Resource limits**: CPU and memory limits set
- **Health checks**: Liveness and readiness probes
- **Graceful shutdown**: Proper termination handling

## 🔐 Security

- **Security groups**: Automated AWS configuration
- **Container security**: Non-root user in containers
- **Network policies**: Kubernetes network isolation
- **Secret management**: Kubernetes secrets for sensitive data

## 📚 Documentation

- [AWS EC2 Deployment Guide](./AWS_EC2_DEPLOYMENT.md)
- [Persistent Deployment Guide](./PERSISTENT_DEPLOYMENT.md)
- [Kubernetes Troubleshooting](./KUBERNETES_DEPLOYMENT.md)
- [API Server Troubleshooting](./API_SERVER_TROUBLESHOOTING.md)
- [Minikube Troubleshooting](./MINIKUBE_TROUBLESHOOTING.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Support

If you encounter issues:
1. Check the relevant troubleshooting guide
2. Review Jenkins build logs
3. Run diagnostic scripts in `./scripts/`
4. Check Kubernetes events and logs

---

# Original Ubuntu EC2 Setup (Alternative Manual Method)

*Note: The Jenkins pipeline automates most of these steps, but they're included for reference.*

## Step 1: Launch an Ubuntu EC2 Instance

1. **Log in to AWS Console:**  
   Open the AWS Management Console and navigate to the EC2 service.
2. **Launch an Instance:**  
   - Click on **Launch Instances**.
   - Select an **Ubuntu Server (e.g., Ubuntu 22.04 LTS)** as the AMI.
   - Choose an instance type (e.g., `t2.micro`).
3. **Configure Security Group:**  
   Allow inbound traffic on port **22 (SSH)** and any other ports required.
4. **Launch & Key Pair:**  
   Launch the instance and download the associated SSH key pair.

*Once your Ubuntu EC2 instance is running, proceed to the next step.*

---

## Step 2: SSH into Your EC2 Instance and Clone Your Repository

1. **Open a Terminal on Your Local Machine.**
2. **SSH into Your Instance:**  
   Replace `mykey.pem` and the host with your actual key file and EC2 public DNS.
   ```bash
   chmod 400 mykey.pem
   ssh -i mykey.pem ubuntu@ec2-xx-xx-xx-xx.compute-1.amazonaws.com
   ```
3. **Update and Install Dependencies:**  
   ```bash
   sudo apt-get update && sudo apt-get upgrade -y
   sudo apt-get install -y python3 python3-pip git
   ```
4. **Clone Your Repository:**  
   ```bash
   git clone https://github.com/AhmadMughal-DS/final_chatbot_for_devops
   ```

*After cloning, continue with the next steps.*

---

## Step 3: Set Up a Python Virtual Environment and Test Your App

1. **Navigate to Your Repository Folder:**  
   ```bash
   cd <YOUR_REPO_FOLDER>
   ```
2. **Create and Activate a Virtual Environment:**  
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```
3. **Install Dependencies:**
   - If using a `requirements.txt` file:
     ```bash
     pip install -r requirements.txt
     ```
   - Otherwise, install manually:
     ```bash
     pip install fastapi uvicorn
     ```
4. **Test-run Your App:**  
   Run the app on port 8000.
   ```bash
   uvicorn main:app --host 0.0.0.0 --port 8000
   ```
5. **Verify in the Browser:**  
   Open your browser and navigate to `http://<EC2_PUBLIC_IP>:8000` to see your app running.

*Press Ctrl+C to stop the server after verification.*

---

## Step 4: Run the FastAPI App in the Background

1. **Run with nohup:**  
   While still in your project folder and with the virtual environment activated, run:
   ```bash
   nohup uvicorn main:app --host 0.0.0.0 --port 8000 &
   ```
   You should see a message like `[1] 12345` indicating the server is running in the background.
2. **Check Logs (Optional):**  
   To monitor log output:
   ```bash
   tail -f nohup.out
   ```

*Your application will keep running even if you disconnect from the SSH session.*

---

# DevOps Chatbot - Phase 4 (Kubernetes Deployment)

Welcome to the Kubernetes deployment guide for the DevOps Chatbot. This project includes Docker containerization, CI/CD pipeline with Jenkins, and Kubernetes deployment with HPA.

## 🏗️ Project Structure

```
final_chatbot_for_devops_phase_4/
├── backend/                          # FastAPI backend application
├── frontend/                         # HTML/CSS/JS frontend
├── tests/                           # Test files
│   └── test_frontend_chat_headless.py # Selenium headless tests
├── scripts/                         # Deployment and utility scripts
│   ├── run_frontend_test.sh         # Frontend test runner
│   ├── deploy_k8s.sh               # Kubernetes deployment script
│   └── cleanup_k8s.sh              # Kubernetes cleanup script
├── k8s-pvc.yaml                    # Kubernetes PersistentVolumeClaims
├── k8s-deployment.yaml             # Kubernetes Deployment
├── k8s-service.yaml                # Kubernetes Services
├── k8s-hpa.yaml                    # Horizontal Pod Autoscaler
├── docker-compose.yml              # Docker Compose configuration
├── Dockerfile                      # Docker container definition
├── Jenkinsfile                     # CI/CD pipeline configuration
└── requirements.txt                # Python dependencies
```

## 🚀 Quick Start (Kubernetes on Minikube)

### Prerequisites
- AWS EC2 t2.large instance
- Minikube installed and running
- kubectl configured
- Docker installed

### Deploy to Kubernetes
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Deploy to Kubernetes
./scripts/deploy_k8s.sh

# Access the application
minikube service devops-chatbot-loadbalancer --url
```

### Cleanup
```bash
./scripts/cleanup_k8s.sh
```

---

# DevOps Chatbot - Kubernetes CI/CD Pipeline

A FastAPI-based DevOps chatbot with robust CI/CD pipeline using Jenkins, Docker, and Kubernetes. Supports both local Minikube and AWS EC2 cloud deployments with automatic environment detection.

## 🚀 Features

- **FastAPI-based chatbot** with MongoDB integration
- **Kubernetes deployment** with auto-scaling (HPA)
- **Jenkins CI/CD pipeline** with automatic environment detection
- **Multi-environment support**: Local Minikube and AWS EC2
- **Persistent deployment** - no automatic teardown
- **Health checks** and automatic restarts
- **Security group management** for AWS deployments
- **Comprehensive testing suite**

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Jenkins       │    │     Docker       │    │   Kubernetes    │
│   Pipeline      │───▶│   Build & Push   │───▶│   Deployment    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                                               │
         └───────────────────────────────────────────────┘
                         Testing & Verification
```

## 📦 Deployment Options

### 🖥️ Local Minikube Deployment
- Automatic Minikube cluster management
- Local Docker registry integration
- Development and testing environment

### 🌩️ AWS EC2 Deployment  
- Automatic AWS environment detection
- Public/Private IP access URLs
- Security group configuration guidance
- Production-ready deployment

## 🚀 Quick Start

### Prerequisites
- Docker installed and running
- Kubernetes (Minikube for local, any cluster for cloud)
- Jenkins with necessary plugins
- Python 3.8+ (for local development)

### 1. Clone Repository
```bash
git clone <your-repo-url>
cd final_chatbot_for_devops_phase_4
```

### 2. Deploy via Jenkins
1. Configure Jenkins with this repository
2. Run the pipeline - it will automatically:
   - Detect your environment (Local/AWS)
   - Build and push Docker images
   - Deploy to Kubernetes
   - Configure auto-scaling
   - Provide access URLs

### 3. Access Your Application
- **Local**: `http://minikube-ip:nodeport`
- **AWS EC2**: `http://public-ip:nodeport`

## 📋 Environment-Specific Guides

### 🖥️ Local Development
See [Local Development Guide](./LOCAL_DEVELOPMENT.md)

### 🌩️ AWS EC2 Deployment
See [AWS EC2 Deployment Guide](./AWS_EC2_DEPLOYMENT.md)

### 🔧 Jenkins Configuration
See [Jenkins Setup Guide](./JENKINS_SETUP.md)

## 🛠️ Manual Management

### Check Deployment Status
```bash
./scripts/check_deployment_status.sh
```

### Test AWS Security Groups
```bash
./scripts/check_aws_security_group.sh
```

### Quick AWS Connectivity Test
```bash
./scripts/quick_aws_test.sh
```

### Stop Application
```bash
./scripts/cleanup_k8s_manual.sh
```

## 🧪 Testing

### Run All Tests
```bash
./scripts/run_tests.sh
```

### Individual Test Categories
```bash
# Backend API tests
python tests/test_chatbot.py

# Kubernetes connectivity tests  
python tests/test_k8s_connectivity.py

# Frontend tests
python tests/test_frontend_chat.py
```

## 📊 Monitoring & Scaling

### View Pod Status
```bash
kubectl get pods -l app=devops-chatbot
```

### Check Auto-scaling
```bash
kubectl get hpa devops-chatbot-hpa
```

### View Logs
```bash
kubectl logs -l app=devops-chatbot --tail=50
```

### Manual Scaling
```bash
kubectl scale deployment devops-chatbot-deployment --replicas=3
```

## 🔧 Configuration Files

| File | Purpose |
|------|---------|
| `Jenkinsfile` | CI/CD pipeline with environment detection |
| `Dockerfile` | Container image configuration |
| `k8s-*.yaml` | Kubernetes deployment manifests |
| `docker-compose.yml` | Local development environment |
| `requirements.txt` | Python dependencies |

## 🚨 Troubleshooting

### Common Issues

1. **Application not accessible externally (AWS)**
   - Check security group configuration
   - Run `./scripts/check_aws_security_group.sh`

2. **Minikube issues**
   - Pipeline includes automatic cluster recovery
   - Check `minikube status`

3. **Build failures**
   - Check Jenkins logs
   - Verify Docker daemon is running

4. **Pod not starting**
   - Check pod logs: `kubectl logs -l app=devops-chatbot`
   - Verify resource limits in k8s manifests

### Debug Commands
```bash
# Check all resources
kubectl get all -l app=devops-chatbot

# Describe deployment
kubectl describe deployment devops-chatbot-deployment

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp

# Test connectivity
curl http://localhost:nodeport
```

## 📈 Performance & Scaling

- **Auto-scaling**: Configured via HPA (2-10 replicas)
- **Resource limits**: CPU and memory limits set
- **Health checks**: Liveness and readiness probes
- **Graceful shutdown**: Proper termination handling

## 🔐 Security

- **Security groups**: Automated AWS configuration
- **Container security**: Non-root user in containers
- **Network policies**: Kubernetes network isolation
- **Secret management**: Kubernetes secrets for sensitive data

## 📚 Documentation

- [AWS EC2 Deployment Guide](./AWS_EC2_DEPLOYMENT.md)
- [Persistent Deployment Guide](./PERSISTENT_DEPLOYMENT.md)
- [Kubernetes Troubleshooting](./KUBERNETES_DEPLOYMENT.md)
- [API Server Troubleshooting](./API_SERVER_TROUBLESHOOTING.md)
- [Minikube Troubleshooting](./MINIKUBE_TROUBLESHOOTING.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Support

If you encounter issues:
1. Check the relevant troubleshooting guide
2. Review Jenkins build logs
3. Run diagnostic scripts in `./scripts/`
4. Check Kubernetes events and logs

---

# Original Ubuntu EC2 Setup (Alternative Manual Method)

*Note: The Jenkins pipeline automates most of these steps, but they're included for reference.*

## Step 1: Launch an Ubuntu EC2 Instance

1. **Log in to AWS Console:**  
   Open the AWS Management Console and navigate to the EC2 service.
2. **Launch an Instance:**  
   - Click on **Launch Instances**.
   - Select an **Ubuntu Server (e.g., Ubuntu 22.04 LTS)** as the AMI.
   - Choose an instance type (e.g., `t2.micro`).
3. **Configure Security Group:**  
   Allow inbound traffic on port **22 (SSH)** and any other ports required.
4. **Launch & Key Pair:**  
   Launch the instance and download the associated SSH key pair.

*Once your Ubuntu EC2 instance is running, proceed to the next step.*

---

## Step 2: SSH into Your EC2 Instance and Clone Your Repository

1. **Open a Terminal on Your Local Machine.**
2. **SSH into Your Instance:**  
   Replace `mykey.pem` and the host with your actual key file and EC2 public DNS.
   ```bash
   chmod 400 mykey.pem
   ssh -i mykey.pem ubuntu@ec2-xx-xx-xx-xx.compute-1.amazonaws.com
   ```
3. **Update and Install Dependencies:**  
   ```bash
   sudo apt-get update && sudo apt-get upgrade -y
   sudo apt-get install -y python3 python3-pip git
   ```
4. **Clone Your Repository:**  
   ```bash
   git clone https://github.com/AhmadMughal-DS/final_chatbot_for_devops
   ```

*After cloning, continue with the next steps.*

---

## Step 3: Set Up a Python Virtual Environment and Test Your App

1. **Navigate to Your Repository Folder:**  
   ```bash
   cd <YOUR_REPO_FOLDER>
   ```
2. **Create and Activate a Virtual Environment:**  
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```
3. **Install Dependencies:**
   - If using a `requirements.txt` file:
     ```bash
     pip install -r requirements.txt
     ```
   - Otherwise, install manually:
     ```bash
     pip install fastapi uvicorn
     ```
4. **Test-run Your App:**  
   Run the app on port 8000.
   ```bash
   uvicorn main:app --host 0.0.0.0 --port 8000
   ```
5. **Verify in the Browser:**  
   Open your browser and navigate to `http://<EC2_PUBLIC_IP>:8000` to see your app running.

*Press Ctrl+C to stop the server after verification.*

---

## Step 4: Run the FastAPI App in the Background

1. **Run with nohup:**  
   While still in your project folder and with the virtual environment activated, run:
   ```bash
   nohup uvicorn main:app --host 0.0.0.0 --port 8000 &
   ```
   You should see a message like `[1] 12345` indicating the server is running in the background.
2. **Check Logs (Optional):**  
   To monitor log output:
   ```bash
   tail -f nohup.out
   ```

*Your application will keep running even if you disconnect from the SSH session.*

---

# DevOps Chatbot - Phase 4 (Kubernetes Deployment)

Welcome to the Kubernetes deployment guide for the DevOps Chatbot. This project includes Docker containerization, CI/CD pipeline with Jenkins, and Kubernetes deployment with HPA.

## 🏗️ Project Structure

```
final_chatbot_for_devops_phase_4/
├── backend/                          # FastAPI backend application
├── frontend/                         # HTML/CSS/JS frontend
├── tests/                           # Test files
│   └── test_frontend_chat_headless.py # Selenium headless tests
├── scripts/                         # Deployment and utility scripts
│   ├── run_frontend_test.sh         # Frontend test runner
│   ├── deploy_k8s.sh               # Kubernetes deployment script
│   └── cleanup_k8s.sh              # Kubernetes cleanup script
├── k8s-pvc.yaml                    # Kubernetes PersistentVolumeClaims
├── k8s-deployment.yaml             # Kubernetes Deployment
├── k8s-service.yaml                # Kubernetes Services
├── k8s-hpa.yaml                    # Horizontal Pod Autoscaler
├── docker-compose.yml              # Docker Compose configuration
├── Dockerfile                      # Docker container definition
├── Jenkinsfile                    