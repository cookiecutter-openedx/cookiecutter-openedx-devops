#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: Feb-2023
#
# usage: Wordpress Kubernetes resources
#------------------------------------------------------------------------------
resource "random_password" "externalDatabasePassword" {
  length           = 16
  special          = true
  override_special = "_%@"
  keepers = {
    version = "1"
  }
}

data "kubernetes_secret" "bastion" {
  metadata {
    name      = "bastion-ssh-key"
    namespace = var.shared_resource_namespace
  }
}

data "kubernetes_secret" "mysql_root" {
  metadata {
    name      = "mysql-root"
    namespace = var.shared_resource_namespace
  }
}

data "kubernetes_secret" "redis" {
  metadata {
    name      = "redis"
    namespace = var.shared_resource_namespace
  }
}

resource "kubernetes_namespace" "wordpress" {
  metadata {
    name = local.wordpressNamespace
  }
}

resource "kubernetes_secret" "wordpress_db" {
  metadata {
    name      = "wordpress-db"
    namespace = local.wordpressNamespace
  }
  data = {
    mariadb-password = random_password.externalDatabasePassword.result
    MYSQL_HOST       = data.kubernetes_secret.mysql_root.data.MYSQL_HOST
    MYSQL_PORT       = data.kubernetes_secret.mysql_root.data.MYSQL_PORT
    MYSQL_DATABASE   = local.externalDatabaseDatabase
    MYSQL_USERNAME   = local.externalDatabaseUser
    MYSQL_PASSWORD   = random_password.externalDatabasePassword.result
    REDIS_HOST       = data.kubernetes_secret.redis.data.REDIS_HOST
    REDIS_PORT       = local.externalCachePort
  }

  depends_on = [
    kubernetes_namespace.wordpress
  ]
}


data "aws_eks_cluster" "eks" {
  name = var.shared_resource_namespace
}

data "aws_eks_cluster_auth" "eks" {
  name = var.shared_resource_namespace
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.eks.token
}
