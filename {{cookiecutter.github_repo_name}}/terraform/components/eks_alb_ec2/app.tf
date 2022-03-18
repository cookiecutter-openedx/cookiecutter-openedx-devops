
data "aws_route53_zone" "environment_domain" {
  name = var.environment_domain
}

resource "kubernetes_namespace" "testapp" {
  metadata {
    labels = {
      app = "my-app"
    }
    name = "testapp-node"
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = "owncloud-server"
    namespace = "testapp-node"
    labels = {
      app = "owncloud"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "owncloud"
      }
    }

    template {
      metadata {
        labels = {
          app = "owncloud"
        }
      }

      spec {
        container {
          image = "owncloud"
          name  = "owncloud-server"

          port {
            container_port = 80
          }
        }
      }
    }
  }
  depends_on = [kubernetes_namespace.testapp]

}

resource "kubernetes_service" "app" {
  metadata {
    name      = "owncloud-service"
    namespace = "testapp-node"
  }
  spec {
    selector = {
      app = "owncloud"
    }

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    type = "NodePort"
  }

  depends_on = [kubernetes_deployment.app]
}

# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress#example-usage
resource "kubernetes_ingress" "app" {
  metadata {
    name      = "owncloud-lb"
    namespace = "testapp-node"
    annotations = {
      "kubernetes.io/ingress.class"           = "alb"
      "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
    }
    labels = {
      "app" = "owncloud"
    }
  }

  spec {
    backend {
      service_name = "owncloud-service"
      service_port = 80
    }
    rule {
      http {
        path {
          path = "/"
          backend {
            service_name = "owncloud-service"
            service_port = 80
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service.app]
}


resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.environment_domain.id
  name    = var.environment_domain
  type    = "CNAME"
  records = [kubernetes_ingress.app.status.0.load_balancer.0.ingress.0.hostname]
}
