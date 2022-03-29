#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: create a kubernetes ingress in the form of an AWS Application Load
#        Balancer (ALB).
#
#------------------------------------------------------------------------------
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
# Amazon EKS pods running on AWS Fargate now support custom security groups
# https://aws.amazon.com/about-aws/whats-new/2021/06/amazon-eks-pods-running-aws-fargate-support-custom-security-groups/
#
# https://github.com/weaveworks/eksctl/issues/1640
# For exposing an HTTP service, it so far only supports ALB with IP mode and you should specify your service as ClusterIP.
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
    type = "ClusterIP"
    selector = {
      App = kubernetes_deployment.nginx.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 80
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
