controller:
  replicaCount: ${replica_count}
  
  service:
    type: LoadBalancer
    annotations:
      cloud.google.com/load-balancer-type: "External"
    externalTrafficPolicy: Local

  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 500m
      memory: 512Mi

  autoscaling:
    enabled: true
    minReplicas: ${replica_count}
    maxReplicas: ${replica_count > 3 ? replica_count * 3 : 9}
    targetCPUUtilizationPercentage: 80
    targetMemoryUtilizationPercentage: 75

  metrics:
    enabled: true
    serviceMonitor:
      enabled: false

  podAnnotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "10254"
    environment: ${environment}
    project: ${project_name}
    cloud-provider: ${cloud_provider}

  config:
    worker-processes: "auto"
    worker-connections: "4096"
    keepalive-timeout: "60"
    server-tokens: "off"
    enable-brotli: "true"
    brotli-level: "6"
    gzip-level: "6"
    ssl-protocols: "TLSv1.2 TLSv1.3"
    ssl-prefer-server-ciphers: "on"
    use-forwarded-headers: "true"
    compute-full-forwarded-for: "true"
    log-format-upstream: '$remote_addr - [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent"'

  affinity:
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          podAffinityTerm:
            labelSelector:
              matchExpressions:
                - key: app.kubernetes.io/name
                  operator: In
                  values:
                    - ingress-nginx
            topologyKey: kubernetes.io/hostname

  tolerations: []

defaultBackend:
  enabled: true
  image:
    repository: registry.k8s.io/defaultbackend-amd64
    tag: "1.5"
  
  resources:
    requests:
      cpu: 10m
      memory: 20Mi
    limits:
      cpu: 20m
      memory: 64Mi
