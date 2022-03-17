
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
