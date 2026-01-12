# Deployment Guide

Choose your approach:

## 1. Terraform Provisioning (Recommended)

Complete infrastructure setup for AWS EKS, GCP GKE, or Azure AKS in Singapore.

See **[TERRAFORM_QUICKSTART.md](TERRAFORM_QUICKSTART.md)** for step-by-step instructions.

This automatically provisions:
- Kubernetes cluster with autoscaling
- NGINX Ingress Controller
- Cert-Manager with Let's Encrypt SSL/TLS
- All networking, security, and IAM

## 2. Manual Deployment on Existing Clusters

If you already have a Kubernetes cluster, deploy just the application.

### Prerequisites

- Kubernetes cluster in Singapore region
- NGINX Ingress Controller installed
- Cert-Manager installed (for SSL/TLS)
- kubectl configured to access your cluster

### Deploy Application

```bash
# Clone repository
git clone https://github.com/pirsquare/kubernetes-lab.git
cd kubernetes-lab

# Deploy using Kustomize (choose your cloud provider)
kustomize build k8s/overlays/aws | kubectl apply -f -
# or
kustomize build k8s/overlays/gcp | kubectl apply -f -
# or
kustomize build k8s/overlays/azure | kubectl apply -f -

# Verify deployment
kubectl get pods -n fastapi-app
kubectl get svc -n fastapi-app
kubectl get ingress -n fastapi-app
```

### Configure Ingress and DNS

```bash
# Get NGINX LoadBalancer IP
kubectl get svc -n ingress-nginx ingress-nginx-controller -w

# Point your domain to this IP
# Update DNS records (A record to LoadBalancer IP)

# Cert-Manager will automatically provision Let's Encrypt certificate
kubectl get certificate -n fastapi-app
```

### Deploy via Argo CD (GitOps)

```bash
# Install Argo CD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Apply the Argo CD application
kubectl apply -f argo/application-aws.yaml
# or: argo/application-gcp.yaml or argo/application-azure.yaml

# Access Argo CD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Username: admin
# Password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## 3. Local Development

```bash
# Setup environment
python -m venv venv
source venv/bin/activate  # or: venv\Scripts\activate on Windows

# Install dependencies
pip install -r app/requirements.txt

# Run application
python app/main.py

# Visit http://localhost:8000/docs for API documentation
```

## Build and Push Docker Image

```bash
# Build image
docker build -t ghcr.io/pirsquare/kubernetes-lab:latest .

# Login to container registry
docker login ghcr.io -u USERNAME -p TOKEN

# Push image
docker push ghcr.io/pirsquare/kubernetes-lab:latest
```

## Troubleshooting

### Check Cluster Status

```bash
# Cluster info
kubectl cluster-info

# Nodes
kubectl get nodes -o wide

# Pods
kubectl get pods -A

# NGINX Ingress
kubectl get pods -n ingress-nginx
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx -f

# Cert-Manager
kubectl get pods -n cert-manager
kubectl logs -n cert-manager -l app=cert-manager -f

# Application
kubectl logs -n fastapi-app -l app=fastapi-app -f
```

### Get LoadBalancer IP

```bash
# Wait for external IP to be assigned
kubectl get svc -n ingress-nginx ingress-nginx-controller -w

# Store it
NGINX_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "NGINX LoadBalancer IP: $NGINX_IP"
```

### Check Certificate Status

```bash
# List certificates
kubectl get certificate -A

# Check certificate details
kubectl describe certificate fastapi-cert -n fastapi-app

# Check issuer
kubectl get clusterissuer
```

## Monitoring

### View Application Metrics

```bash
# Port forward to Prometheus (if available)
kubectl port-forward -n fastapi-app svc/fastapi-app 9090:9090

# Access at http://localhost:9090
```

### View Logs

```bash
# Application logs
kubectl logs -n fastapi-app -l app=fastapi-app -f

# NGINX logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx -f

# Real-time pod status
kubectl get pods -n fastapi-app -w
```

## Next Steps

1. **Production Setup**: Use Terraform for infrastructure
2. **Domain Configuration**: Point DNS to NGINX LoadBalancer IP
3. **GitOps Setup**: Configure Argo CD for continuous deployment
4. **Monitoring**: Set up alerts with cloud provider monitoring
5. **Backup**: Configure etcd backups via cloud provider

## Support

- See [README.md](README.md) for overview
- See [TERRAFORM_QUICKSTART.md](TERRAFORM_QUICKSTART.md) for infrastructure setup
- See [ARCHITECTURE.md](ARCHITECTURE.md) for design details
