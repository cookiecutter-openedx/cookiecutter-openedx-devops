#------------------------------------------------------------------------------ 
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: March-2022
#
# usage: build an EKS cluster load balancer that uses a Fargate Compute Cluster
#------------------------------------------------------------------------------

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

#------------------------------------------------------------------------------
# Harshet Jain: Now create a namespace, deployment, and service for our app.
#------------------------------------------------------------------------------
resource "kubernetes_namespace" "fargate" {
  metadata {
    name = "openedx"
  }
    name = "fargate-node"
  }


resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.cluster_name}"
   
  role_arn = aws_iam_role.eks_cluster_role.arn
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  
   vpc_config {
    subnet_ids =  concat(var.public_subnets, var.private_subnets)
  }
   
   timeouts {
     delete    = "30m"
   }
}

#------------------------------------------------------------------------------ 
# Harshet Jain: create a deployment for our app with the help of a 
# Docker image to run the pod(s).
#------------------------------------------------------------------------------ 
resource "kubernetes_deployment" "app" {
  metadata {
    name      = "owncloud-server"
    namespace = "fargate-node"
    labels    = {
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
   depends_on = [kubernetes_namespace.fargate]
}

#------------------------------------------------------------------------------ 
# Harshet Jain: create a service for load balancing.
#------------------------------------------------------------------------------ 
resource "kubernetes_service" "app" {
  metadata {
    name      = "owncloud-service"
    namespace = "fargate-node"
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

