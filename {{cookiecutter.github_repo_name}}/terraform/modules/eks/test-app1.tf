# https://www.itwonderlab.com/en/kubernetes-with-terraform/

#-----------------------------------------
# KUBERNETES DEPLOYMENT COLOR APP
#-----------------------------------------
resource "kubernetes_deployment" "color" {
  metadata {
    name = "color-blue-dep"
    labels = {
      app   = "color"
      color = "blue"
    }
  }

  spec {
    selector {
      match_labels = {
        app   = "color"
        color = "blue"
      }
    }
    replicas = 3

    #Template for the creation of the pod
    template {
      metadata {
        labels = {
          app   = "color"
          color = "blue"
        }
      }
      spec {
        container {
          image = "itwonderlab/color" #Docker image name
          name  = "color-blue"        #Name of the container specified as a DNS_LABEL. Each container in a pod must have a unique name (DNS_LABEL).

          #Block of string name and value pairs to set in the container's environment
          env {
            name  = "COLOR"
            value = "blue"
          }

          #List of ports to expose from the container.
          port {
            container_port = 8080
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
}

#-------------------------------------------------
# KUBERNETES DEPLOYMENT COLOR SERVICE NODE PORT
#-------------------------------------------------
resource "kubernetes_service" "color-service-np" {
  metadata {
    name = "color-service-np"
  }
  spec {
    selector = {
      app = "color"
    }
    session_affinity = "ClientIP"
    port {
      port      = 8080
      node_port = 30085
    }
    type = "NodePort"
  }
}
