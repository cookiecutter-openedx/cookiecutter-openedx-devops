#------------------------------------------------------------------------------ 
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: temporary placeholder in lieue of Github Actions deployment
#------------------------------------------------------------------------------ 

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}


resource "kubernetes_namespace" "fargate" {
  metadata {
    labels = {
      app = "my-app"
    }
    name = "fargate-node"
  }
}


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