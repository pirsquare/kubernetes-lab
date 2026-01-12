terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
}

# Create namespace
resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = var.kubernetes_namespace
    labels = {
      "app.kubernetes.io/name" = "ingress-nginx"
      environment              = var.environment
      project                  = var.project_name
    }
  }
}

# Deploy NGINX Ingress Controller via Helm
resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = kubernetes_namespace.ingress_nginx.metadata[0].name
  version          = var.nginx_version
  create_namespace = false

  values = [
    templatefile("${path.module}/values.yaml.tpl", {
      replica_count     = var.replica_count
      environment       = var.environment
      project_name      = var.project_name
      cloud_provider    = var.cloud_provider
    })
  ]

  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }

  set {
    name  = "controller.podAnnotations.prometheus\\.io/scrape"
    value = "true"
  }

  set {
    name  = "controller.podAnnotations.prometheus\\.io/port"
    value = "10254"
  }

  depends_on = [kubernetes_namespace.ingress_nginx]
}

# Wait for NGINX service to get LoadBalancer IP
resource "time_sleep" "wait_for_loadbalancer" {
  depends_on = [helm_release.nginx_ingress]

  create_duration = "30s"
}

# Get LoadBalancer service info
data "kubernetes_service" "nginx_ingress" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
  }

  depends_on = [time_sleep.wait_for_loadbalancer]
}

# ConfigMap for NGINX configuration
resource "kubernetes_config_map" "nginx_config" {
  metadata {
    name      = "nginx-configuration"
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
  }

  data = {
    "worker-processes"    = "auto"
    "worker-connections"  = "4096"
    "keepalive-timeout"   = "60"
    "client-body-timeout" = "60"
    "client-header-timeout" = "60"
    "server-tokens"       = "off"
    "enable-brotli"       = "true"
    "brotli-level"        = "6"
    "gzip-level"          = "6"
    "ssl-protocols"       = "TLSv1.2 TLSv1.3"
    "ssl-prefer-server-ciphers" = "on"
    "ssl-ciphers"         = "ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-CHACHA20-POLY1305"
    "use-forwarded-headers" = "true"
    "compute-full-forwarded-for" = "true"
    "use-proxy-protocol"   = "false"
    "log-format-upstream"  = "$remote_addr - $remote_user [$time_local] \"$request\" $status $body_bytes_sent \"$http_referer\" \"$http_user_agent\" \"$http_x_forwarded_for\" \"$host\" sn=\"$server_name\" rt=$request_time ua=\"$upstream_addr\" us=\"$upstream_status\" ut=\"$upstream_response_time\" ul=\"$upstream_response_length\" cs=$upstream_cache_status"
  }

  depends_on = [helm_release.nginx_ingress]
}

# HorizontalPodAutoscaler for NGINX Controller
resource "kubernetes_manifest" "nginx_hpa" {
  manifest = {
    apiVersion = "autoscaling/v2"
    kind       = "HorizontalPodAutoscaler"
    metadata = {
      name      = "ingress-nginx-controller"
      namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
    }
    spec = {
      scaleTargetRef = {
        apiVersion = "apps/v1"
        kind       = "Deployment"
        name       = "ingress-nginx-controller"
      }
      minReplicas = var.replica_count
      maxReplicas = var.replica_count * 3
      metrics = [
        {
          type = "Resource"
          resource = {
            name = "cpu"
            target = {
              type                = "Utilization"
              averageUtilization  = 80
            }
          }
        },
        {
          type = "Resource"
          resource = {
            name = "memory"
            target = {
              type                = "Utilization"
              averageUtilization  = 75
            }
          }
        }
      ]
    }
  }

  depends_on = [helm_release.nginx_ingress]
}

# PodDisruptionBudget for NGINX Controller
resource "kubernetes_manifest" "nginx_pdb" {
  manifest = {
    apiVersion = "policy/v1"
    kind       = "PodDisruptionBudget"
    metadata = {
      name      = "ingress-nginx-controller"
      namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
    }
    spec = {
      minAvailable = max(1, var.replica_count - 1)
      selector = {
        matchLabels = {
          "app.kubernetes.io/name"     = "ingress-nginx"
          "app.kubernetes.io/component" = "controller"
        }
      }
    }
  }

  depends_on = [helm_release.nginx_ingress]
}

# NetworkPolicy to restrict traffic
resource "kubernetes_manifest" "nginx_network_policy" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "NetworkPolicy"
    metadata = {
      name      = "ingress-nginx-policy"
      namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
    }
    spec = {
      podSelector = {
        matchLabels = {
          "app.kubernetes.io/name" = "ingress-nginx"
        }
      }
      policyTypes = ["Ingress", "Egress"]
      ingress = [
        {
          from = [
            {
              namespaceSelector = {}
            }
          ]
          ports = [
            {
              protocol = "TCP"
              port     = 80
            },
            {
              protocol = "TCP"
              port     = 443
            },
            {
              protocol = "TCP"
              port     = 8443
            }
          ]
        }
      ]
      egress = [
        {
          to = [
            {
              namespaceSelector = {}
            }
          ]
          ports = [
            {
              protocol = "TCP"
              port     = 0
            }
          ]
        },
        {
          to = [
            {
              podSelector = {}
            }
          ]
        }
      ]
    }
  }

  depends_on = [helm_release.nginx_ingress]
}
