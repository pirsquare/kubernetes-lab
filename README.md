# FastAPI Kubernetes Lab

A production-ready Kubernetes deployment setup for a FastAPI Python application with multi-cloud support (AWS EKS, Google GKE, Azure AKS) targeting Singapore region for optimal performance. Uses NGINX Ingress controller, Argo CD for GitOps, and automated CI/CD via GitHub Actions.

## 🚀 Features

- **FastAPI Application**: Production-ready Python web API with health checks and metrics
- **AlmaLinux Container**: Secure, enterprise-ready Linux base image
- **Multi-Cloud Deployment**: Kustomize overlays for AWS (ap-southeast-1), GCP (asia-southeast1), Azure (southeastasia)
- **Singapore-Optimized**: All regions configured for fastest latency from Singapore
- **NGINX Ingress**: Standard Kubernetes ingress controller with automatic SSL via cert-manager
- **GitOps with Argo CD**: Automated deployment synchronization from Git
- **CI/CD Pipeline**: GitHub Actions workflows for build, test, deploy, and security
- **Kubernetes Best Practices**:
  - Resource requests and limits
  - Health checks (liveness and readiness probes)
  - Horizontal Pod Autoscaling (HPA)
  - Pod Disruption Budgets (PDB)
  - Network Policies
  - Non-root user execution
- **Security**: Container vulnerability scanning, dependency checks
- **Clean & Maintainable**: No unnecessary files, focused tooling


## 🛠️ Prerequisites

- **Local Development**:
  - Python 3.11+
  - Docker & Docker Buildx
  - kubectl
  - kustomize
  - Git

- **Cloud Infrastructure**:
  - AWS: EKS cluster with IAM roles
  - GCP: GKE cluster with service accounts
  - Azure: AKS cluster with RBAC

- **GitOps**:
  - Argo CD installed on target clusters
  - GitHub repository with push access
  - GitHub Actions enabled

## 🚢 Getting Started

### 1. Clone Repository

```bash
# Clone the pirsquare kubernetes-lab repository
git clone https://github.com/pirsquare/kubernetes-lab.git
cd kubernetes-lab
```

### 2. Local Development

```bash
# Create Python virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r app/requirements.txt
pip install pytest pytest-cov httpx

# Run the application locally
python app/main.py
# Visit http://localhost:8000/docs for API documentation
```

### 3. Build Docker Image

```bash
# Build using Docker
docker build -t fastapi-app:latest .

# Or with BuildKit for better caching
docker buildx build --load -t fastapi-app:latest .

# Run the container
docker run -p 8000:8000 fastapi-app:latest
```

### 4. Deploy to Kubernetes

```bash
# Deploy to AWS EKS (Singapore - ap-southeast-1)
kustomize build k8s/overlays/aws | kubectl apply -f -

# Or deploy to GCP GKE (Singapore - asia-southeast1)
kustomize build k8s/overlays/gcp | kubectl apply -f -

# Or deploy to Azure AKS (Singapore - southeastasia)
kustomize build k8s/overlays/azure | kubectl apply -f -

# Verify deployment
kubectl get pods -n fastapi-app
kubectl get svc -n fastapi-app
kubectl get ingress -n fastapi-app
```

## 🔄 GitOps with Argo CD

### Installation & Configuration

```bash
# Install Argo CD namespace
kubectl create namespace argocd

# Install Argo CD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Port-forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Deploy Applications

```bash
# Apply Argo CD applications (pirsquare/kubernetes-lab)
kubectl apply -f argo/appproject.yaml
kubectl apply -f argo/application-aws.yaml
kubectl apply -f argo/application-gcp.yaml
kubectl apply -f argo/application-azure.yaml

# Monitor sync status
argocd app list
argocd app get fastapi-app-aws
argocd app sync fastapi-app-aws
```

## 🌐 NGINX Ingress & SSL

### Installation

```bash
# Install NGINX Ingress Controller (already included in deployment guides)
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer
```

### Access Application

```bash
# Get NGINX LoadBalancer endpoint
kubectl get svc -n ingress-nginx

# Point your domain (api.example.com) to the LoadBalancer IP
# SSL certificates are automatically provisioned via cert-manager
```

## 🔐 Security Configuration

### Network Policy

The deployment includes network policies that:
- Restrict ingress to the fastapi-app namespace
- Allow egress for DNS and service communication
- Can be customized per cloud provider

### Pod Security

- Runs as non-root user (UID 1000)
- Read-only root filesystem
- No privileged escalation
- Resource limits enforced

### Image Scanning

```bash
# Trivy scanning (automatic via GitHub Actions)
trivy image ghcr.io/YOUR_ORG/kubernetes-lab:latest

# Manual security checks
bandit -r app/
safety check -r app/requirements.txt
```

## 📊 Monitoring & Observability

### Health Checks

- **Liveness Probe**: `/health` - Checks if container is alive
- **Readiness Probe**: `/readiness` - Checks if container is ready for traffic
- **Metrics Endpoint**: `/metrics` - Prometheus-compatible metrics

```bash
# Check pod health
kubectl get pods -n fastapi-app
kubectl describe pod <pod-name> -n fastapi-app

# View logs
kubectl logs <pod-name> -n fastapi-app -f
```

### Horizontal Pod Autoscaling

The deployment includes HPA configured for:
- CPU utilization threshold: 70%
- Memory utilization threshold: 80%
- Min replicas: 3
- Max replicas: 10

```bash
# Monitor HPA
kubectl get hpa -n fastapi-app
kubectl describe hpa fastapi-app -n fastapi-app
```

## 🔄 CI/CD Workflows

### Build Workflow (`.github/workflows/build.yml`)

Triggered on:
- Push to main/develop
- Pull requests

Performs:
- Docker image build and push to AlmaLinux base
- Python unit tests
- Code coverage reports

### Deploy Workflow (`.github/workflows/deploy.yml`)

Triggered on:
- Push to main branch
- Manual workflow dispatch

Performs:
- AWS/GCP/Azure authentication
- Kustomize build and kubectl apply
- Argo CD sync (for main branch)

### Security Workflow (`.github/workflows/security.yml`)

Runs on:
- Push and pull requests
- Daily schedule (2 AM UTC)

Performs:
- Trivy container vulnerability scanning
- Dependency vulnerability checks
- Kubeval Kubernetes manifest validation
- kubesec security scoring

## 🔐 GitHub Secrets

Configure these secrets in your repository settings:

```
# AWS
AWS_ROLE_ARN              # IAM role for OIDC

# GCP
GCP_SA_KEY               # Service account JSON key
GCP_PROJECT_ID           # GCP project ID

# Azure
AZURE_CREDENTIALS        # Azure service principal JSON

# Argo CD
ARGOCD_SERVER           # Argo CD server URL
ARGOCD_AUTH_TOKEN       # Argo CD API token

# Container Registry
GITHUB_TOKEN            # GitHub container registry token (auto-provided)
```

## 📝 API Endpoints

```
GET  /                   # Root endpoint
GET  /health             # Health check
GET  /readiness          # Readiness check
GET  /docs               # Swagger UI
GET  /openapi.json       # OpenAPI schema
GET  /api/v1/info        # Application info
GET  /api/v1/data/{id}   # Get data item
POST /api/v1/data        # Create data item
GET  /metrics            # Prometheus metrics
```

## 🧪 Testing

```bash
# Unit tests
pytest app/tests/ -v

# Code coverage
pytest app/tests/ --cov=app --cov-report=html

# Manual API testing
curl http://localhost:8000/health
curl http://localhost:8000/api/v1/info
```

## 🤝 Contributing

1. Create a feature branch
2. Make changes and commit
3. Push to GitHub
4. Create a pull request
5. Workflows will run automatically
6. Merge after approval

## 📄 License

MIT License - see LICENSE file for details

## 👨‍💻 Author

Created for multi-cloud Kubernetes deployment lab

---

**Questions?** Check [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment instructions.

