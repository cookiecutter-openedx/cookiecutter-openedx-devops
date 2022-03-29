# -----------------------------------------------------------------------------
#
# https://learn.hashicorp.com/tutorials/terraform/kubernetes-provider
#
# -----------------------------------------------------------------------------
locals {
  namespace = "application"
}

data "aws_acm_certificate" "issued" {
  domain   = var.environment_domain
  statuses = ["ISSUED"]
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    namespace = local.namespace
    name      = "nginx"
    labels = {
      App = "nginx"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "nginx"
      }
    }
    template {
      metadata {
        labels = {
          App = "nginx"
        }
      }
      spec {
        container {
          image = "nginx:latest"
          name  = "nginx"

          port {
            name           = "web"
            container_port = 80
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
  depends_on = [helm_release.alb_controller]
}

#------------------------------------------------------------------------------
# see: https://stackoverflow.com/questions/43789155/nodeport-service-is-not-externally-accessible-via-port-number
#      https://stackoverflow.com/questions/70924215/aws-fargate-backed-eks-application-not-reachable-over-loadbalancer-service
#
#      https://github.com/weaveworks/eksctl/issues/1640
#      For exposing an HTTP service, it so far only supports ALB with IP mode and you should specify your service as ClusterIP.
#
# suppose your applied Kubernetes Services looks like this
#     Name:                     ingress-service
#     Namespace:                application
#     Labels:                   <none>
#     Annotations:              alb.ingress.kubernetes.io/target-type: ip
#     Selector:                 App=nginx
#     Type:                     NodePort
#     IP Family Policy:         SingleStack
#     IP Families:              IPv4
#     IP:                       10.100.114.227
#     IPs:                      10.100.114.227
#     Port:                     <unset>  8090/TCP
#     TargetPort:               80/TCP
#     NodePort:                 <unset>  31000/TCP
#     Endpoints:                192.168.4.227:80,192.168.5.101:80
#     Session Affinity:         None
#     External Traffic Policy:  Cluster
#     Events:                   <none>
#
#   curl <node-ip>:<node-port>        # curl <node-ip>:31000
#   curl <service-ip>:<service-port>  # curl <svc-ip>:8090
#   curl <pod-ip>:<target-port>       # curl <pod-ip>:80
#
# 1. You are inside the kubernetes cluster (you are a pod)
#     <service-ip> and <pod-ip> and <node-ip> will work.
#
# 2. You are on the node
#     <service-ip> and <pod-ip> and <node-ip> will work.
#
# 3. You are outside the node
#     Only <node-ip> will work assuming that <node-ip> is reachable.
#
#------------------------------------------------------------------------------
resource "kubernetes_service" "nginx" {
  metadata {
    name      = "ingress-service"
    namespace = local.namespace
    annotations = {
      "alb.ingress.kubernetes.io/target-type" = "ip"
    }
  }
  spec {
    #type = "NodePort"
    type = "ClusterIP"
    selector = {
      App = kubernetes_deployment.nginx.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 80
      node_port   = 31000
      protocol    = "TCP"
    }

  }
  depends_on = [kubernetes_deployment.nginx]
}

resource "kubernetes_ingress" "nginx" {
  wait_for_load_balancer = true
  metadata {
    name      = "ingress-nginx"
    namespace = local.namespace
    labels = {
      "app" = "nginx"
    }
    # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/ingress/annotations/
    # https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/
    annotations = {
      "kubernetes.io/ingress.class"                            = "alb"
      "alb.ingress.kubernetes.io/scheme"                       = "internet-facing"
      "alb.ingress.kubernetes.io/load-balancer-name"           = var.environment_namespace
      "alb.ingress.kubernetes.io/certificate-arn"              = data.aws_acm_certificate.issued.arn
      "alb.ingress.kubernetes.io/ip-address-type"              = "ipv4"
      "alb.ingress.kubernetes.io/security-groups"              = aws_security_group.sg_alb.id,
      "alb.ingress.kubernetes.io/ssl-redirect"                 = "443"
      "alb.ingress.kubernetes.io/backend-protocol"             = "HTTP"
      "alb.ingress.kubernetes.io/healthcheck-port"             = "80"
      "alb.ingress.kubernetes.io/healthcheck-path"             = "/"
      "alb.ingress.kubernetes.io/healthcheck-interval-seconds" = "15"
      "alb.ingress.kubernetes.io/healthcheck-timeout-seconds"  = "5"
      "alb.ingress.kubernetes.io/healthy-threshold-count"      = "2"
      "alb.ingress.kubernetes.io/unhealthy-threshold-count"    = "2"
      "alb.ingress.kubernetes.io/success-codes"                = "200-399"
      "alb.ingress.kubernetes.io/target-node-labels"           = "label1=nginx"
      "alb.ingress.kubernetes.io/listen-ports"                 = jsonencode([{ "HTTP" : 80 }, { "HTTPS" : 443 }])
      "alb.ingress.kubernetes.io/tags"                         = "Environment=${var.environment_namespace}"
    }
  }

  spec {
    tls {
      hosts = [
        "fargate.stepwise.ai"
      ]
    }
    backend {
      service_name = kubernetes_service.nginx.metadata.0.name
      service_port = 80
    }
    rule {
      http {
        path {
          path = "/*"
          backend {
            service_name = kubernetes_service.nginx.metadata.0.name
            service_port = 80
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.alb_controller,
    aws_security_group.sg_alb,
    kubernetes_deployment.nginx,
    kubernetes_service.nginx
  ]
}
