# -----------------------------------------------------------------------------
#
# https://learn.hashicorp.com/tutorials/terraform/kubernetes-provider
#
# -----------------------------------------------------------------------------

# Create a local variable for the load balancer name.
locals {
  lb_name = split("-", split(".", kubernetes_service.nginx.status.0.load_balancer.0.ingress.0.hostname).0).0
}

# Read information about the load balancer using the AWS provider.
data "aws_elb" "app" {
  name = local.lb_name
}


resource "kubernetes_deployment" "nginx" {
  metadata {
    namespace = "ingress-alb-controller"
    name      = "scalable-nginx-example"
    labels = {
      App = "ScalableNginxExample"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "ScalableNginxExample"
      }
    }
    template {
      metadata {
        labels = {
          App = "ScalableNginxExample"
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
  depends_on = [module.alb_controller]
}

resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx-example"
  }
  spec {
    selector = {
      App = kubernetes_deployment.nginx.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 8080
      target_port = 80
    }

    type = "LoadBalancer"
  }
}
