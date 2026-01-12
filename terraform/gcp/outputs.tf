output "gke_cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.main.name
}

output "gke_cluster_endpoint" {
  description = "GKE cluster API endpoint"
  value       = google_container_cluster.main.endpoint
}

output "gke_cluster_location" {
  description = "GKE cluster location"
  value       = google_container_cluster.main.location
}

output "gke_node_pool_name" {
  description = "GKE node pool name"
  value       = google_container_node_pool.main.name
}

output "network_name" {
  description = "VPC network name"
  value       = google_compute_network.main.name
}

output "subnet_name" {
  description = "Subnet name"
  value       = google_compute_subnetwork.main.name
}

output "nginx_ingress_namespace" {
  description = "NGINX Ingress namespace"
  value       = module.nginx_ingress.namespace
}

output "nginx_service_endpoint" {
  description = "NGINX Ingress Controller service endpoint (LoadBalancer)"
  value       = module.nginx_ingress.service_endpoint
}

output "kubeconfig_command" {
  description = "Command to update kubeconfig"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.main.name} --zone ${var.gcp_region} --project ${var.gcp_project_id}"
}
