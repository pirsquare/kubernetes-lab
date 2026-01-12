# FastAPI Kubernetes Lab

Production-ready Kubernetes deployment for a FastAPI application with multi-cloud support (AWS EKS, GCP GKE, Azure AKS) in Singapore. Includes Terraform for infrastructure, NGINX Ingress, Argo CD for GitOps, and CI/CD automation.

## 🚀 Features

- **FastAPI Application** - Production-ready API with metrics and health checks
- **Infrastructure as Code** - Terraform for AWS/GCP/Azure provisioning
- **Multi-Cloud** - EKS, GKE, AKS all in Singapore region
- **NGINX Ingress** - Auto-deployed with Let's Encrypt SSL/TLS
- **GitOps with Argo CD** - Automated deployment from Git
- **CI/CD Pipeline** - GitHub Actions for build, test, deploy
- **AlmaLinux Container** - Secure enterprise Linux base image
- **Kubernetes Best Practices** - HPA, PDB, network policies, resource limits

## 📋 Prerequisites

- Terraform >= 1.0
- Cloud provider CLI: AWS CLI, gcloud, or az
- kubectl
- Git
- Cloud accounts (AWS/GCP/Azure)

**For local development**: Python 3.11, Docker, kustomize

## � Quick Start

### Terraform Provisioning (Recommended)

```bash
# Clone repository
git clone https://github.com/pirsquare/kubernetes-lab.git
cd kubernetes-lab/terraform/{aws,gcp,azure}

# Configure
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Deploy cluster + NGINX + cert-manager
terraform init
terraform plan
terraform apply

# Get kubeconfig (provider-specific)
# AWS: aws eks update-kubeconfig --region ap-southeast-1 --name kubernetes-lab-cluster
# GCP: gcloud container clusters get-credentials kubernetes-lab-cluster --zone asia-southeast1
# Azure: az aks get-credentials --resource-group kubernetes-lab-rg --name kubernetes-lab-cluster

# Verify
kubectl get nodes
kubectl get pods -n ingress-nginx
```

For detailed instructions, see [TERRAFORM_QUICKSTART.md](TERRAFORM_QUICKSTART.md)

### Local Development

```bash
# Setup Python environment
python -m venv venv
source venv/bin/activate
pip install -r app/requirements.txt

# Run locally
python app/main.py
# Visit http://localhost:8000/docs
```

### Build Docker Image

```bash
docker build -t fastapi-app:latest .
docker run -p 8000:8000 fastapi-app:latest
```

### Manual Kubernetes Deployment

```bash
# Deploy application only (requires existing cluster + NGINX)
kustomize build k8s/overlays/aws | kubectl apply -f -
# or: k8s/overlays/gcp or k8s/overlays/azure
```

## 📚 Documentation

- **[TERRAFORM_QUICKSTART.md](TERRAFORM_QUICKSTART.md)** - Terraform setup guide
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Manual deployment (existing clusters)
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Architecture overview
- **[UPDATES.md](UPDATES.md)** - Recent changes

## 🔄 GitOps with Argo CD

```bash
# Install Argo CD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Port forward for UI access
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Deploy application
kubectl apply -f argo/application-aws.yaml
# or: argo/application-gcp.yaml or argo/application-azure.yaml
```

## 📁 Project Structure

```
kubernetes-lab/
├── terraform/           # Infrastructure as Code
│   ├── aws/            # EKS cluster (ap-southeast-1)
│   ├── gcp/            # GKE cluster (asia-southeast1)
│   ├── azure/          # AKS cluster (southeastasia)
│   └── modules/        # Reusable NGINX module
│
├── app/                # FastAPI application
│   ├── main.py
│   ├── requirements.txt
│   └── tests/
│
├── k8s/                # Kubernetes manifests
│   ├── base/           # Cloud-agnostic base configs
│   └── overlays/       # Cloud-specific overlays
│
├── argo/               # Argo CD applications
├── .github/workflows/  # CI/CD pipelines
├── Dockerfile          # AlmaLinux-based image
└── bootstrap.sh        # Optional setup script
```

## 🔐 Security

- AlmaLinux 9 container base (enterprise-grade)
- Network policies restrict traffic
- RBAC and IAM properly configured
- Let's Encrypt SSL/TLS automation
- Non-root container execution
- Container vulnerability scanning (Trivy)
- Dependency checks (Safety)

## 🎯 Regions (Singapore)

- **AWS**: ap-southeast-1
- **GCP**: asia-southeast1  
- **Azure**: southeastasia

## 📈 Next Steps

1. Choose your cloud provider
2. Follow [TERRAFORM_QUICKSTART.md](TERRAFORM_QUICKSTART.md) to deploy
3. Configure DNS pointing to NGINX LoadBalancer IP
4. Deploy application via Argo CD or Kustomize
5. Monitor via cloud provider dashboards

## 📞 Support

- [Terraform Docs](https://www.terraform.io/docs)
- [NGINX Ingress Docs](https://kubernetes.github.io/ingress-nginx/)
- [Cert-Manager Docs](https://cert-manager.io/)
- [Argo CD Docs](https://argo-cd.readthedocs.io/)


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


