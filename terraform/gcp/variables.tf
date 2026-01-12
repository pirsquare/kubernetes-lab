variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region (Singapore)"
  type        = string
  default     = "asia-southeast1"
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

variable "subnet_cidr" {
  description = "Subnet CIDR range"
  type        = string
  default     = "10.0.0.0/20"
}

variable "pods_cidr" {
  description = "Secondary IP range for pods"
  type        = string
  default     = "10.4.0.0/14"
}

variable "services_cidr" {
  description = "Secondary IP range for services"
  type        = string
  default     = "10.0.16.0/20"
}

variable "node_initial_count" {
  description = "Initial number of worker nodes"
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

variable "node_machine_type" {
  description = "Machine type for worker nodes"
  type        = string
  default     = "e2-medium"
}

variable "node_disk_size_gb" {
  description = "Disk size in GB for worker nodes"
  type        = number
  default     = 50
}

variable "node_preemptible" {
  description = "Use preemptible nodes to save costs"
  type        = bool
  default     = false
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
