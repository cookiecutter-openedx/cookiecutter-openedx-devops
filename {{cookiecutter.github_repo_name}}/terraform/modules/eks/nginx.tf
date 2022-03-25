# -----------------------------------------------------------------------------
#
# https://learn.hashicorp.com/tutorials/terraform/kubernetes-provider
#
# -----------------------------------------------------------------------------

# Create a local variable for the load balancer name.
locals {
  lb_name   = split("-", split(".", kubernetes_ingress.nginx.status.0.load_balancer.0.ingress.0.hostname).0).0
  namespace = "ingress-alb-controller"
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    namespace = local.namespace
    name      = "scalable-nginx-example"
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
          image = "nginx:1.7.8"
          name  = "example"

          port {
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

resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx-service"
  }
  spec {
    type = "NodePort"
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
    name      = "nginx-lb"
    namespace = local.namespace
    annotations = {
      "kubernetes.io/ingress.class"           = "alb"
      "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
    }
    labels = {
      "app" = "nginx"
    }
  }

  spec {
    backend {
      service_name = "nginx-service"
      service_port = 80
    }
    rule {
      http {
        path {
          path = "/"
          backend {
            service_name = "nginx-service"
            service_port = 80
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service.nginx]
}
