variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "azure_region" {
  description = "Azure region (Singapore)"
  type        = string
  default     = "southeastasia"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "kubernetes-lab"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "vnet_cidr" {
  description = "Virtual Network CIDR range"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "Subnet CIDR range"
  type        = string
  default     = "10.0.1.0/24"
}

variable "service_cidr" {
  description = "Kubernetes service CIDR range"
  type        = string
  default     = "10.1.0.0/16"
}

variable "dns_service_ip" {
  description = "Kubernetes DNS service IP"
  type        = string
  default     = "10.1.0.10"
}

variable "docker_bridge_cidr" {
  description = "Docker bridge network CIDR"
  type        = string
  default     = "172.17.0.1/16"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "node_desired_count" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 3
}

variable "node_min_count" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 3
}

variable "node_max_count" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 10
}

variable "node_vm_size" {
  description = "VM size for worker nodes"
  type        = string
  default     = "Standard_B2s"
}

variable "node_disk_size_gb" {
  description = "Disk size in GB for worker nodes"
  type        = number
  default     = 50
}

variable "nginx_namespace" {
  description = "Kubernetes namespace for NGINX Ingress"
  type        = string
  default     = "ingress-nginx"
}

variable "nginx_version" {
  description = "NGINX Ingress Controller version"
  type        = string
  default     = "4.9.0"
}

variable "nginx_replica_count" {
  description = "Number of NGINX Ingress replicas"
  type        = number
  default     = 3
}

variable "cert_manager_version" {
  description = "Cert-Manager version"
  type        = string
  default     = "v1.13.0"
}

variable "acme_email" {
  description = "Email for ACME certificate registration"
  type        = string
  default     = "admin@example.com"
}
