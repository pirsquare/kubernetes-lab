# Kubernetes Lab - Architecture & Setup Overview

## 📊 Project Architecture

Singapore-Optimized Multi-Cloud Deployment with NGINX Ingress:

```
┌─────────────────────────────────────────────────────────────────┐
│          GitHub Repository (pirsquare/kubernetes-lab)           │
├─────────────────────────────────────────────────────────────────┤
│                    GitHub Actions CI/CD                          │
│  ┌────────────┬──────────────┬─────────────────────────────┐    │
│  │   Build    │   Security   │        Deploy & Sync        │    │
│  │ (AlmaLinux)│   Scan       │   (Argo CD)                 │    │
│  └────────────┴──────────────┴─────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
          │                │                │
    ┌─────▼──────┐    ┌────▼────────┐    ┌──▼──────────┐
    │AWS EKS      │    │GCP GKE      │    │Azure AKS    │
    │(ap-se-1)   │    │(asia-se1)   │    │(southeastasia)
    ├─────────────┤    ├─────────────┤    ├─────────────┤
    │Argo CD      │    │Argo CD      │    │Argo CD      │
    │             │    │             │    │             │
    │NGINX LB     │    │NGINX LB     │    │NGINX LB     │
    │             │    │             │    │             │
    │FastAPI App  │    │FastAPI App  │    │FastAPI App  │
    │(3+ Pods)    │    │(3+ Pods)    │    │(3+ Pods)    │
    │HPA, PDB     │    │HPA, PDB     │    │HPA, PDB     │
    └─────────────┘    └─────────────┘    └─────────────┘
```

## 🗂️ Directory Structure

### App Directory
```
app/
├── main.py              # FastAPI application with routes
├── requirements.txt     # Python dependencies
└── tests/
    ├── __init__.py
    └── test_main.py     # Unit tests
```

**Key Features:**
- FastAPI with async/await support
- Health and readiness probes
- Prometheus metrics endpoint
- CORS middleware
- Pydantic models for type safety
- OpenAPI documentation

### Kubernetes Directory - Base Configuration

```
k8s/base/
├── namespace.yaml           # Namespace creation
├── serviceaccount.yaml      # Service account for RBAC
├── configmap.yaml           # Application configuration
├── deployment.yaml          # Main deployment with:
│                             # - 3 replicas
│                             # - Resource limits
│                             # - Health checks
│                             # - Security context
├── service.yaml             # ClusterIP service
├── hpa.yaml                 # Horizontal Pod Autoscaling
├── pdb.yaml                 # Pod Disruption Budget
├── networkpolicy.yaml       # Network security
└── kustomization.yaml       # Kustomize base config
```

**Key Features:**
- Non-root user execution (UID 1000)
- Resource requests and limits
- Liveness & readiness probes
- Horizontal Pod Autoscaling (3-10 replicas)
- Network policies for security
- Pod Disruption Budget for HA

### Kubernetes Directory - Cloud Overlays

```
k8s/overlays/
├── aws/
│   ├── kustomization.yaml       # AWS-specific config
│   ├── deployment-patch.yaml    # AWS node selectors
│   └── ingress.yaml             # AWS ALB Ingress
├── gcp/
│   ├── kustomization.yaml       # GCP-specific config
│   ├── deployment-patch.yaml    # GCP node selectors
│   └── ingress.yaml             # GCP Load Balancer
└── azure/
    ├── kustomization.yaml       # Azure-specific config
    ├── deployment-patch.yaml    # Azure node selectors
    └── ingress.yaml             # Azure Application Gateway
```

**Overlay Features:**
- Cloud-specific Ingress controllers
- Node affinity and selectors
- Regional configuration
- Load balancer settings

### Argo CD Directory

```
argo/
├── appproject.yaml              # Argo CD Project definition
├── application-aws.yaml         # AWS deployment app
├── application-gcp.yaml         # GCP deployment app
├── application-azure.yaml       # Azure deployment app
└── notifications-config.yaml    # Slack notifications
```

**Features:**
- Automated sync policies
- Self-healing enabled
- Notification webhooks
- Retry policies
- Revision history

### GitHub Actions Directory

```
.github/workflows/
├── build.yml                    # Docker build & push
├── deploy.yml                   # Kubernetes deployment
├── security.yml                 # Security scanning
└── lint.yml                     # Code quality checks
```

## 🔄 CI/CD Pipeline Flow

### Build Workflow
```
Git Push → Build Docker Image → Run Tests → Push to Registry
```

Triggers:
- Push to main/develop
- Pull requests

Actions:
- Multi-stage Docker build
- Unit test execution
- Code coverage analysis
- Image push to GitHub Container Registry

### Deploy Workflow
```
Push to main → Kustomize Build → Kubectl Apply → Argo Sync
```

Triggers:
- Push to main branch
- Manual workflow dispatch

Actions:
- Cloud provider authentication (AWS/GCP/Azure)
- Cluster credentials configuration
- Kustomize manifest build
- Kubectl apply
- Argo CD synchronization

### Security Workflow
```
Scan Container → Scan Code → Validate Manifests → Report Issues
```

Triggers:
- Daily schedule (2 AM UTC)
- Push events
- Pull requests

Scans:
- Trivy container vulnerability scanning
- Bandit Python code analysis
- Kubeval Kubernetes manifest validation
- kubesec security scoring

### Lint Workflow
```
Check Code Style → Format Check → Validate YAML → Lint Dockerfile
```

Checks:
- Black Python formatting
- isort import sorting
- Flake8 linting
- yamllint YAML validation
- hadolint Dockerfile validation

## 🚀 Deployment Flow

### Local Development
```
code → venv → pytest → docker build → kubectl apply
```

### Production (with GitOps)
```
git push → GitHub Actions → Docker Registry
                    ↓
            Argo CD detects changes
                    ↓
          Kustomize builds manifests
                    ↓
         Deploys to target cluster
```

## 📋 Configuration Management

### ConfigMap
- Environment variables (ENVIRONMENT, LOG_LEVEL)
- Cloud provider detection
- Application settings

### Secrets (Manual Setup Required)
- Container registry credentials
- Cloud provider credentials
- API keys

## 🔐 Security Implementation

### Network Security
- NetworkPolicy restricts traffic
- Ingress from designated namespaces only
- Egress for DNS and internal services

### Pod Security
- Non-root user (UID 1000)
- Resource limits enforced
- Read-only root filesystem option
- No privileged escalation

### Image Security
- Multi-stage Docker build (smaller images)
- Non-root base image
- Health checks in Dockerfile
- Regular vulnerability scanning

## 📊 Observability

### Health Checks
```
/health      → Liveness probe (30s interval)
/readiness   → Readiness probe (10s interval)
/metrics     → Prometheus metrics endpoint
```

### HPA Metrics
- CPU utilization: 70% threshold
- Memory utilization: 80% threshold
- Min/Max replicas: 3-10

### Logging
- Structured logging to stdout
- Log level configuration
- Pod log aggregation via kubectl

## 🛠️ Technology Stack

### Application
- Python 3.11
- FastAPI web framework
- Uvicorn ASGI server
- Pydantic data validation

### Container
- **AlmaLinux 9** enterprise-ready base image
- Multi-stage Docker build
- Non-root user execution

### Orchestration
- Kubernetes (EKS/GKE/AKS)
- Kustomize for config management

### Ingress & Networking
- **NGINX Ingress Controller** (standard, cloud-agnostic)
- cert-manager for SSL/TLS
- Automatic certificate provisioning via Let's Encrypt

### GitOps
- Argo CD for deployment automation
- GitHub as source of truth
- Automated sync and self-healing

### CI/CD
- GitHub Actions for automation
- Docker Buildx for image building
- AlmaLinux-based container images

### Security
- Trivy for vulnerability scanning
- Safety for dependency checks
- Network policies
- Non-root user execution
- Resource limits

### Regional Distribution (Singapore-Optimized)
- **AWS**: ap-southeast-1 (Singapore)
- **GCP**: asia-southeast1 (Singapore)
- **Azure**: southeastasia (Singapore)

## 📝 Key Files & Their Purposes

| File | Purpose |
|------|---------|
| `app/main.py` | FastAPI application code |
| `Dockerfile` | AlmaLinux-based container image |
| `k8s/base/deployment.yaml` | Base deployment config |
| `k8s/overlays/*/` | Cloud-specific overrides |
| `argo/application-*.yaml` | Argo CD app definitions |
| `.github/workflows/` | CI/CD pipeline definitions |
| `pyproject.toml` | Python tool configuration |
| `bootstrap.sh` | Local environment setup |

## 🚀 Quick Start Commands

```bash
# Local development
pip install -r app/requirements.txt
pip install pytest pytest-cov httpx

# Run tests
pytest app/tests/ -v

# Docker (AlmaLinux-based)
docker build -t fastapi-app:latest .
docker run -p 8000:8000 fastapi-app:latest

# Kubernetes deployment (Singapore-optimized)
kubectl apply -k k8s/overlays/aws/             # AWS ap-southeast-1
kubectl apply -k k8s/overlays/gcp/             # GCP asia-southeast1
kubectl apply -k k8s/overlays/azure/           # Azure southeastasia

# Monitoring
kubectl get pods -n fastapi-app
kubectl logs -n fastapi-app -l app=fastapi-app -f
kubectl get ingress -n fastapi-app
```

## 📚 Related Documentation

- [README.md](README.md) - Main project documentation
- [DEPLOYMENT.md](DEPLOYMENT.md) - Detailed deployment guide
- FastAPI: https://fastapi.tiangolo.com/
- Kubernetes: https://kubernetes.io/docs/
- Argo CD: https://argo-cd.readthedocs.io/
- GitHub Actions: https://docs.github.com/en/actions

## 🎯 Next Steps

1. **Configure GitHub Secrets** for cloud provider access
2. **Update Argo Applications** with your repository URL
3. **Create cloud clusters** (EKS/GKE/AKS)
4. **Install Argo CD** on target clusters
5. **Deploy Argo applications** via kubectl
6. **Monitor deployments** via Argo CD UI
7. **Configure domain** and SSL certificates
8. **Set up monitoring** (Prometheus/Grafana)
9. **Configure logging** (ELK/Loki)
10. **Implement backup** and disaster recovery
