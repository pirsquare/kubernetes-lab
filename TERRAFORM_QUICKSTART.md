# Terraform Quick Start

Deploy Kubernetes infrastructure in Singapore with Terraform.

## AWS EKS (Singapore: ap-southeast-1)

```bash
aws configure

cd terraform/aws
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars

terraform init
terraform plan
terraform apply

# Get kubeconfig
aws eks update-kubeconfig --region ap-southeast-1 --name kubernetes-lab-cluster

# Verify
kubectl get nodes
kubectl get pods -n ingress-nginx
```

## GCP GKE (Singapore: asia-southeast1)

```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID

cd terraform/gcp
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars

terraform init
terraform plan
terraform apply

# Get kubeconfig
gcloud container clusters get-credentials kubernetes-lab-cluster --zone asia-southeast1

# Verify
kubectl get nodes
kubectl get pods -n ingress-nginx
```

## Azure AKS (Singapore: southeastasia)

```bash
az login
az account set --subscription YOUR_SUBSCRIPTION_ID

cd terraform/azure
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars

terraform init
terraform plan
terraform apply

# Get kubeconfig
az aks get-credentials --resource-group kubernetes-lab-rg --name kubernetes-lab-cluster

# Verify
kubectl get nodes
kubectl get pods -n ingress-nginx
```

## What Gets Provisioned

- ✅ Kubernetes cluster (3 nodes, autoscaling 3-10)
- ✅ NGINX Ingress Controller (3 replicas)
- ✅ Cert-Manager with Let's Encrypt
- ✅ VPC/VNet with subnets
- ✅ IAM/RBAC properly configured
- ✅ Network policies for security

## After Deployment

### Get NGINX LoadBalancer IP

```bash
kubectl get svc -n ingress-nginx ingress-nginx-controller

# Copy the EXTERNAL-IP (or EXTERNAL-HOSTNAME)
NGINX_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo $NGINX_IP
```

### Configure DNS

Point your domain's A record to the NGINX LoadBalancer IP.

### Deploy Application

```bash
# Via Argo CD (GitOps - Recommended)
kubectl apply -f argo/application-aws.yaml
# or: argo/application-gcp.yaml or argo/application-azure.yaml

# Or manually with Kustomize
kustomize build k8s/overlays/aws | kubectl apply -f -
# or: k8s/overlays/gcp or k8s/overlays/azure
```

### Verify Everything

```bash
kubectl get pods -A
kubectl get ingress -A
kubectl get certificate -A
```

## Common Commands

### View Outputs

```bash
terraform output
terraform output nginx_service_endpoint
```

### Update Configuration

```bash
nano terraform.tfvars
terraform plan
terraform apply
```

### Destroy Infrastructure

```bash
terraform destroy
```

### Debug

```bash
export TF_LOG=DEBUG
terraform plan
```

## Configuration Variables

All three clouds support these main variables (see `terraform.tfvars.example`):

- `project_name` - Project name (default: kubernetes-lab)
- `environment` - Environment (default: production)
- `kubernetes_version` - K8s version (default: 1.28)
- `nginx_replica_count` - NGINX replicas (default: 3)
- `acme_email` - Let's Encrypt email
- `node_*` - Node count/type (cloud-specific)

## Estimated Monthly Costs (Singapore)

| Provider | Compute | Kubernetes | Total |
|----------|---------|------------|-------|
| AWS | ~$30 (t3.medium x3) | $73 | ~$103 |
| GCP | ~$20 (e2-medium x3) | $74 | ~$94 |
| Azure | ~$25 (B2s x3) | Free | ~$25 |

*Prices vary by region. Use provider pricing calculators for exact costs.*

## Troubleshooting

### LoadBalancer IP pending

```bash
# Wait 2-3 minutes, then check again
kubectl get svc -n ingress-nginx -w
```

### Certificate not issuing

```bash
# Check cert-manager logs
kubectl logs -n cert-manager -l app=cert-manager -f

# View certificate status
kubectl describe certificate -n fastapi-app
```

### Cluster connection issues

```bash
# Verify kubeconfig
kubectl cluster-info

# Check nodes
kubectl get nodes -o wide

# Check NGINX
kubectl get pods -n ingress-nginx
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx -f
```

## Next Steps

1. Deploy cluster with Terraform (choose AWS/GCP/Azure above)
2. Get NGINX LoadBalancer IP
3. Configure DNS pointing to LoadBalancer IP
4. Deploy application (Argo CD or Kustomize)
5. Monitor via cloud provider dashboards

## Support

- [Terraform Docs](https://www.terraform.io/docs)
- [NGINX Ingress](https://kubernetes.github.io/ingress-nginx/)
- [Cert-Manager](https://cert-manager.io/)
- [Argo CD](https://argo-cd.readthedocs.io/)
