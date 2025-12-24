# DevOps Chatbot - Kubernetes CI/CD Pipeline

A production-ready FastAPI chatbot with MongoDB integration, featuring automated CI/CD pipeline using Jenkins, Docker, and Kubernetes with horizontal auto-scaling capabilities.

## 🎯 Project Overview

This project demonstrates a complete DevOps workflow from development to production deployment, showcasing:
- **Containerization** with Docker and Docker Compose
- **Orchestration** using Kubernetes with auto-scaling (HPA)
- **CI/CD Automation** through Jenkins pipeline
- **Cloud Deployment** on AWS EC2 with Minikube
- **Infrastructure as Code** with declarative Kubernetes manifests
- **Automated Testing** for functionality validation

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Jenkins       │    │     Docker       │    │   Kubernetes    │
│   Pipeline      │───▶│   Build & Push   │───▶│   + HPA         │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                                              │
         │                                              │
         ▼                                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     User Interface (Frontend)                   │
│                     ↓                                           │
│                FastAPI Backend + MongoDB                        │
└─────────────────────────────────────────────────────────────────┘
```

## 🛠️ Technology Stack

- **Backend**: FastAPI (Python)
- **Database**: MongoDB
- **Frontend**: HTML, CSS, JavaScript
- **Containerization**: Docker, Docker Compose
- **Orchestration**: Kubernetes (Minikube for local, AWS EC2 for cloud)
- **CI/CD**: Jenkins
- **Testing**: Selenium, Pytest
- **Infrastructure**: AWS EC2, Kubernetes HPA

## 📁 Project Structure

```
final_chatbot_for_devops_phase_4/
├── backend/
│   ├── main.py                     # FastAPI application
│   └── curd_mongodb.py             # MongoDB operations
├── frontend/
│   ├── index.html                  # Landing page
│   ├── signin.html                 # User authentication
│   ├── signup.html                 # User registration
│   ├── chat.html                   # Chat interface
│   └── welcome.html                # Welcome page
├── tests/
│   ├── test_chatbot.py             # Backend API tests
│   ├── test_frontend_chat.py       # Frontend integration tests
│   ├── test_frontend_chat_headless.py  # Selenium tests
│   ├── test_k8s_chatbot.py         # Kubernetes deployment tests
│   ├── test_multiple_queries.py    # Load testing
│   └── test_signup.py              # Authentication tests
├── scripts/
│   ├── build_docker.sh             # Docker image building
│   ├── deploy_k8s.sh               # Kubernetes deployment
│   ├── cleanup_k8s.sh              # Resource cleanup
│   ├── quick_aws_test.sh           # AWS connectivity test
│   └── run_frontend_test.sh        # Frontend test runner
├── k8s-deployment.yaml             # Kubernetes deployment config
├── k8s-service.yaml                # Kubernetes service config
├── k8s-hpa.yaml                    # Horizontal Pod Autoscaler
├── k8s-pvc.yaml                    # Persistent Volume Claims
├── docker-compose.yml              # Multi-container setup
├── Dockerfile                      # Container image definition
├── Jenkinsfile                     # CI/CD pipeline
└── requirements.txt                # Python dependencies
```

## 🚀 Quick Start

### Option 1: Docker Compose (Local Development)

```bash
# Build and run with Docker Compose
docker-compose up --build

# Access the application
# Frontend: http://localhost:8080
# Backend API: http://localhost:8000
```

### Option 2: Kubernetes Deployment

#### Prerequisites
- Minikube installed and running
- kubectl configured
- Docker installed

#### Deploy to Kubernetes
```bash
# Start Minikube
minikube start --cpus=2 --memory=4096

# Make scripts executable
chmod +x scripts/*.sh

# Deploy to Kubernetes
./scripts/deploy_k8s.sh

# Get the application URL
minikube service devops-chatbot-loadbalancer --url
```

#### Cleanup
```bash
./scripts/cleanup_k8s.sh
```

### Option 3: Jenkins CI/CD Pipeline

1. **Setup Jenkins** on your local machine or AWS EC2 instance
2. **Create a new Pipeline job** in Jenkins
3. **Point to the Jenkinsfile** in this repository
4. **Run the pipeline** - it will automatically:
   - Build Docker images
   - Push to Docker Hub (if configured)
   - Deploy to Kubernetes
   - Run tests
   - Provide access URLs

## 📊 Features

### Backend Features
- RESTful API using FastAPI
- MongoDB integration for data persistence
- User authentication (signup/signin)
- Chatbot conversation handling
- Health check endpoints

### Frontend Features
- Responsive web interface
- User registration and authentication
- Real-time chat interface
- Session management

### DevOps Features
- **Containerization**: Multi-stage Docker builds for optimized images
- **Orchestration**: Kubernetes deployments with replica management
- **Auto-scaling**: Horizontal Pod Autoscaler (HPA) based on CPU utilization
- **Persistent Storage**: PersistentVolumeClaims for MongoDB data
- **CI/CD Pipeline**: Automated build, test, and deployment
- **Environment Detection**: Automatic AWS/local environment configuration
- **Health Monitoring**: Readiness and liveness probes

## 🧪 Testing

```bash
# Run all tests
pytest tests/

# Run specific test suites
pytest tests/test_chatbot.py          # Backend tests
pytest tests/test_k8s_chatbot.py      # Kubernetes tests
pytest tests/test_frontend_chat.py    # Frontend tests
```

## 📝 Configuration

### Environment Variables
- `MONGODB_URL`: MongoDB connection string
- `PORT`: Application port (default: 8000)

### Kubernetes Configuration
- **Replicas**: 2 (configurable in k8s-deployment.yaml)
- **HPA**: 2-10 pods based on 50% CPU utilization
- **Resources**: 
  - Requests: 100m CPU, 128Mi memory
  - Limits: 500m CPU, 512Mi memory

## 🚀 Deployment Guide

### AWS EC2 Deployment

1. **Launch EC2 Instance** (t2.large recommended)
   ```bash
   # Ubuntu 22.04 LTS
   # Security Group: Allow ports 22 (SSH), 80, 8000, 30000-32767
   ```

2. **Install Dependencies**
   ```bash
   # Install Docker
   sudo apt-get update
   sudo apt-get install -y docker.io
   sudo usermod -aG docker $USER

   # Install Minikube
   curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
   sudo install minikube-linux-amd64 /usr/local/bin/minikube

   # Install kubectl
   sudo snap install kubectl --classic
   ```

3. **Deploy Application**
   ```bash
   git clone <your-repo-url>
   cd final_chatbot_for_devops_phase_4
   ./scripts/deploy_k8s.sh
   ```

4. **Access Application**
   - Get your EC2 public IP
   - Access via: `http://<EC2-PUBLIC-IP>:<NodePort>`

## 📈 Monitoring

### Check Deployment Status
```bash
# View pods
kubectl get pods

# View services
kubectl get svc

# View HPA status
kubectl get hpa

# View logs
kubectl logs -f <pod-name>
```

### Jenkins Pipeline Monitoring
- Build history and console output
- Test results and reports
- Deployment status notifications

## 🔧 Troubleshooting

### Common Issues

1. **Minikube not starting**
   ```bash
   minikube delete
   minikube start --driver=docker --cpus=2 --memory=4096
   ```

2. **Pods not running**
   ```bash
   kubectl describe pod <pod-name>
   kubectl logs <pod-name>
   ```

3. **Service not accessible**
   ```bash
   # Check service
   kubectl get svc
   
   # For Minikube
   minikube service list
   minikube service devops-chatbot-loadbalancer --url
   ```

## 🤝 Contributing

This project was developed as a comprehensive DevOps demonstration. Feel free to:
- Fork the repository
- Submit pull requests
- Report issues
- Suggest improvements

## 📄 License

This project is open-source and available for educational purposes.

## 👤 Author

**Ahmad Mughal**
- GitHub: [@AhmadMughal-DS](https://github.com/AhmadMughal-DS)

## 🌟 Key Takeaways

This project demonstrates:
- ✅ Complete CI/CD pipeline implementation
- ✅ Container orchestration with Kubernetes
- ✅ Infrastructure as Code practices
- ✅ Automated testing and deployment
- ✅ Cloud deployment on AWS
- ✅ Production-ready application architecture
- ✅ DevOps best practices and methodologies

---

**Built with ❤️ for DevOps Excellence**
