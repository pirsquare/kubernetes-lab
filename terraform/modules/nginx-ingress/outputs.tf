output "namespace" {
  description = "NGINX Ingress namespace"
  value       = kubernetes_namespace.ingress_nginx.metadata[0].name
}

output "service_name" {
  description = "NGINX Ingress Controller service name"
  value       = "ingress-nginx-controller"
}

output "service_namespace" {
  description = "NGINX Ingress Controller service namespace"
  value       = kubernetes_namespace.ingress_nginx.metadata[0].name
}

output "service_endpoint" {
  description = "NGINX Ingress Controller LoadBalancer IP/Endpoint"
  value       = try(
    data.kubernetes_service.nginx_ingress.status[0].load_balancer[0].ingress[0].hostname != "" ? 
    data.kubernetes_service.nginx_ingress.status[0].load_balancer[0].ingress[0].hostname :
    data.kubernetes_service.nginx_ingress.status[0].load_balancer[0].ingress[0].ip,
    "LoadBalancer IP pending..."
  )
}

output "helm_release_name" {
  description = "Helm release name"
  value       = helm_release.nginx_ingress.name
}

output "helm_release_version" {
  description = "Helm release version"
  value       = helm_release.nginx_ingress.version
}
