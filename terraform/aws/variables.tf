variable "aws_region" {
  description = "AWS region (Singapore)"
  type        = string
  default     = "ap-southeast-1"
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

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 3
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 3
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 10
}

variable "node_instance_types" {
  description = "EC2 instance types for worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks that can access the cluster endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
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
