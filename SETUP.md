# Project Setup

## Simple Setup

Everything is set up for easy deployment. Just follow one of these:

### 🚀 Quick Deploy (Terraform - Recommended)

```bash
git clone https://github.com/pirsquare/kubernetes-lab.git
cd kubernetes-lab/terraform/{aws,gcp,azure}

cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars

terraform init
terraform apply
```

See [TERRAFORM_QUICKSTART.md](TERRAFORM_QUICKSTART.md) for detailed instructions.

### 🔧 Manual Setup (Existing Cluster)

If you already have a Kubernetes cluster:

```bash
git clone https://github.com/pirsquare/kubernetes-lab.git
cd kubernetes-lab

kustomize build k8s/overlays/aws | kubectl apply -f -
# or: k8s/overlays/gcp or k8s/overlays/azure
```

See [DEPLOYMENT.md](DEPLOYMENT.md) for details.

### 💻 Local Development

```bash
python -m venv venv
source venv/bin/activate
pip install -r app/requirements.txt
python app/main.py
```

## Documentation

| Document | Purpose |
|----------|---------|
| [README.md](README.md) | Project overview |
| [TERRAFORM_QUICKSTART.md](TERRAFORM_QUICKSTART.md) | Deploy infrastructure (AWS/GCP/Azure) |
| [DEPLOYMENT.md](DEPLOYMENT.md) | Application deployment on existing clusters |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Architecture & design details |
| [UPDATES.md](UPDATES.md) | Recent changes summary |

## Infrastructure

Terraform automatically provisions:

- ✅ Kubernetes cluster (EKS/GKE/AKS)
- ✅ NGINX Ingress Controller
- ✅ Cert-Manager with Let's Encrypt
- ✅ Networking (VPC/VNet)
- ✅ IAM/RBAC
- ✅ Auto-scaling

## What's Included

```
kubernetes-lab/
├── terraform/          # Infrastructure as Code (primary provisioning)
│   ├── aws/           # EKS in Singapore (ap-southeast-1)
│   ├── gcp/           # GKE in Singapore (asia-southeast1)
│   ├── azure/         # AKS in Singapore (southeastasia)
│   └── modules/       # Reusable NGINX module
│
├── app/               # FastAPI application
├── k8s/               # Kubernetes manifests
├── argo/              # Argo CD GitOps configs
├── .github/           # GitHub Actions CI/CD
└── Dockerfile         # AlmaLinux container
```

## Getting Started

1. **Clone**: `git clone https://github.com/pirsquare/kubernetes-lab.git`
2. **Choose method**: Terraform (easiest) or manual deployment
3. **Follow guide**: See README or TERRAFORM_QUICKSTART.md
4. **Deploy**: Run terraform apply or kubectl commands
5. **Done**: Infrastructure ready in 10-15 minutes

## Regions

All services deployed in Singapore for best latency:
- AWS: ap-southeast-1
- GCP: asia-southeast1
- Azure: southeastasia

## Need Help?

- **Terraform setup**: See [TERRAFORM_QUICKSTART.md](TERRAFORM_QUICKSTART.md)
- **Manual deployment**: See [DEPLOYMENT.md](DEPLOYMENT.md)
- **Architecture questions**: See [ARCHITECTURE.md](ARCHITECTURE.md)
- **Recent changes**: See [UPDATES.md](UPDATES.md)
