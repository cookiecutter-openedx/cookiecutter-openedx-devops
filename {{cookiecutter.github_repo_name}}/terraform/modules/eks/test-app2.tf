
resource "kubernetes_deployment" "app" {
  metadata {
    name = "owncloud-server"
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

}

resource "kubernetes_service" "app" {
  metadata {
    name = "owncloud-service"
  }
  spec {
    selector = {
      app = kubernetes_deployment.app.spec.0.template.0.metadata.0.labels.app
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

resource "kubernetes_ingress" "app" {
  metadata {
    name = "owncloud-lb"
    #annotations = {
    #  "kubernetes.io/ingress.class"           = "alb"
    #  "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
    #  "alb.ingress.kubernetes.io/target-type" = "ip"
    #}
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
