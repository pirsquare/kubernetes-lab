# Deployment Guide

This guide provides step-by-step instructions for deploying the FastAPI application to Kubernetes across different cloud providers using Singapore regions.

## Table of Contents

1. [Initial Setup](#initial-setup)
2. [AWS EKS Deployment](#aws-eks-deployment)
3. [Google GKE Deployment](#google-gke-deployment)
4. [Azure AKS Deployment](#azure-aks-deployment)
5. [NGINX Ingress Setup](#nginx-ingress-setup)
6. [Argo CD GitOps Setup](#argo-cd-gitops-setup)
7. [Monitoring and Troubleshooting](#monitoring-and-troubleshooting)

## Initial Setup

### 1. Configure Repository

Update clone the repository with pirsquare:

```bash
git clone https://github.com/pirsquare/kubernetes-lab.git
cd kubernetes-lab
```

### 2. Create Container Registry

```bash
# Enable GitHub Container Registry
# Go to https://github.com/settings/packages
# Create a Personal Access Token with `write:packages` scope

# Login to GitHub Container Registry
docker login ghcr.io -u USERNAME -p TOKEN
```

### 3. Configure GitHub Secrets

Add these secrets to your GitHub repository (Settings → Secrets):

#### AWS Secrets

```bash
# 1. Create IAM role for GitHub Actions OIDC
aws iam create-role --role-name github-actions-role \
  --assume-role-policy-document file://trust-policy.json

# 2. Attach policies
aws iam attach-role-policy --role-name github-actions-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy

# 3. Get the role ARN
aws iam get-role --role-name github-actions-role --query 'Role.Arn'
```

Add to GitHub Secrets:
- `AWS_ROLE_ARN`: ARN from above

## AWS EKS Deployment (Singapore - ap-southeast-1)

### 1. Create EKS Cluster

```bash
# Set variables
export AWS_REGION=ap-southeast-1
export CLUSTER_NAME=fastapi-cluster
export NODE_COUNT=3

# Create EKS cluster in Singapore
eksctl create cluster \
  --name $CLUSTER_NAME \
  --region $AWS_REGION \
  --nodes $NODE_COUNT \
  --node-type t3.medium \
  --with-oidc \
  --enable-ssm

# Update kubeconfig
aws eks update-kubeconfig \
  --name $CLUSTER_NAME \
  --region $AWS_REGION
```

### 2. Install Required Components

```bash
# Install metrics-server for HPA
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Install NGINX Ingress Controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer

# Install cert-manager for SSL certificates
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Install Argo CD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 3. Deploy Application

```bash
# Deploy using kustomize overlay
kustomize build k8s/overlays/aws | kubectl apply -f -

# Verify deployment
kubectl get pods -n fastapi-app -w

# Get service endpoint
kubectl get svc -n fastapi-app fastapi-app

# Get ingress details
kubectl get ingress -n fastapi-app
```

### 4. Configure Ingress

Get the NGINX Ingress LoadBalancer IP:

```bash
kubectl get svc -n ingress-nginx nginx-ingress-ingress-nginx-controller

# Update your DNS to point to the LoadBalancer IP
# Then configure cert-manager ClusterIssuer for SSL
```

## Google GKE Deployment (Singapore - asia-southeast1)

### 1. Create GKE Cluster

```bash
# Set variables
export PROJECT_ID=your-project-id
export CLUSTER_NAME=fastapi-cluster
export REGION=asia-southeast1
export ZONE=asia-southeast1-a

# Create GKE cluster in Singapore
gcloud container clusters create $CLUSTER_NAME \
  --project=$PROJECT_ID \
  --zone=$ZONE \
  --num-nodes=3 \
  --machine-type=n1-standard-2 \
  --enable-autoscaling \
  --min-nodes=3 \
  --max-nodes=10 \
  --enable-stackdriver-kubernetes

# Get credentials
gcloud container clusters get-credentials $CLUSTER_NAME \
  --zone=$ZONE \
  --project=$PROJECT_ID
```

### 2. Install Required Components

```bash
# Install metrics-server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Install Argo CD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 3. Deploy Application

```bash
# Deploy using kustomize overlay
kustomize build k8s/overlays/gcp | kubectl apply -f -

# Verify deployment
kubectl get pods -n fastapi-app -w

# Create static IP
gcloud compute addresses create fastapi-app-ip --global

# Update ingress with static IP
kubectl get ingress -n fastapi-app
```

### 4. Configure SSL Certificate

```bash
# Apply cert-manager ClusterIssuer
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF

# DNS will auto-resolve with NGINX LoadBalancer IP
```

## Azure AKS Deployment (Singapore - southeastasia)

### 1. Create AKS Cluster

```bash
# Set variables
export RESOURCE_GROUP=fastapi-rg
export CLUSTER_NAME=fastapi-cluster
export LOCATION=southeastasia

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create AKS cluster in Singapore region
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --node-count 3 \
  --vm-set-type VirtualMachineScaleSets \
  --load-balancer-sku standard \
  --enable-managed-identity \
  --network-plugin azure

# Get credentials
az aks get-credentials \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME
```

### 2. Install Required Components

```bash
# Install metrics-server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Install NGINX Ingress Controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer

# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Install Argo CD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 3. Deploy Application

```bash
# Deploy using kustomize overlay
kustomize build k8s/overlays/azure | kubectl apply -f -

# Verify deployment
kubectl get pods -n fastapi-app -w

# Check ingress
kubectl get ingress -n fastapi-app
```

## NGINX Ingress Setup

### 1. Install NGINX Ingress Controller

```bash
# Add NGINX Helm repo
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install NGINX Ingress Controller
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer \
  --set controller.replicaCount=3

# Get the LoadBalancer IP (this is your public endpoint)
kubectl get svc -n ingress-nginx nginx-ingress-ingress-nginx-controller
```

### 2. Configure DNS

Point your domain to the NGINX LoadBalancer IP:

```bash
# Get the LoadBalancer IP/Hostname
NGINX_IP=$(kubectl get svc -n ingress-nginx nginx-ingress-ingress-nginx-controller \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  
echo "Point api.example.com to: $NGINX_IP"
```

### 3. Install cert-manager for SSL

```bash
# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Create ClusterIssuer for Let's Encrypt
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
```

## Argo CD GitOps Setup

### 1. Install Argo CD (if not already installed)

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 2. Access Argo CD

```bash
# Port-forward to Argo CD server
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d

# Access at https://localhost:8080
# Username: admin
# Password: [from above]
```

### 3. Add GitHub Repository

```bash
# Generate GitHub personal access token with repo and admin:repo_hook permissions

argocd repo add https://github.com/YOUR_ORG/kubernetes-lab \
  --username your-username \
  --password your-token \
  --insecure-skip-server-verification
```

### 4. Create Argo CD Applications

```bash
# Apply Argo CD configurations
kubectl apply -f argo/appproject.yaml
kubectl apply -f argo/application-aws.yaml
kubectl apply -f argo/application-gcp.yaml
kubectl apply -f argo/application-azure.yaml

# Monitor applications
argocd app list
```

### 5. Configure Notifications

Update `argo/notifications-config.yaml` with your Slack webhook:

```bash
kubectl create secret generic argocd-notifications-secret \
  -n argocd \
  --from-literal=slack-token=xoxb-YOUR-TOKEN
```

Apply:
```bash
kubectl apply -f argo/notifications-config.yaml -n argocd
```

## Monitoring and Troubleshooting

### Check Deployment Status

```bash
# Check pods
kubectl get pods -n fastapi-app

# Check services
kubectl get svc -n fastapi-app

# Check ingress
kubectl get ingress -n fastapi-app

# Check HPA
kubectl get hpa -n fastapi-app
```

### View Logs

```bash
# Application logs
kubectl logs -n fastapi-app -l app=fastapi-app -f

# Previous logs (if crashed)
kubectl logs -n fastapi-app -l app=fastapi-app --previous

# Argo CD logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server -f
```

### Debugging

```bash
# Describe pod
kubectl describe pod <pod-name> -n fastapi-app

# Execute into pod
kubectl exec -it <pod-name> -n fastapi-app -- /bin/bash

# Port-forward to pod
kubectl port-forward <pod-name> 8000:8000 -n fastapi-app
```

### Common Issues

#### 1. Pods stuck in Pending

```bash
# Check node capacity
kubectl describe nodes

# Check resource requests vs available
kubectl top nodes
```

#### 2. Ingress not routing traffic

```bash
# Verify ingress configuration
kubectl get ingress -n fastapi-app -o yaml

# Check ingress controller logs
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
```

#### 3. Application not ready

```bash
# Check readiness probe
kubectl describe pod <pod-name> -n fastapi-app

# Check application logs
kubectl logs <pod-name> -n fastapi-app
```

### Health Checks

```bash
# Test application endpoints
kubectl port-forward svc/fastapi-app 8000:80 -n fastapi-app

# In another terminal:
curl http://localhost:8000/health
curl http://localhost:8000/api/v1/info
curl http://localhost:8000/docs
```

## Next Steps

1. Configure domain name and DNS
2. Set up monitoring (Prometheus/Grafana)
3. Configure logging (ELK/Loki)
4. Set up backup and disaster recovery
5. Implement RBAC and network policies
6. Configure resource quotas and limits

For more information, see [README.md](README.md).
