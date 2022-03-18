#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#
# usage: this is a temporary module, for development and testing purposes.
#        creates a simple placeholder app using the `owncloud` container
#------------------------------------------------------------------------------

data "aws_route53_zone" "environment_domain" {
  name = var.environment_domain
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = "owncloud-server"
    namespace = "ec2-node"
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
  depends_on = [kubernetes_namespace.ec2]

}

resource "kubernetes_service" "app" {
  metadata {
    name      = "owncloud-service"
    namespace = "ec2-node"
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
