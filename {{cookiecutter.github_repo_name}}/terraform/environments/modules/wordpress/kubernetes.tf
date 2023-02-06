#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: April 2022
#
# usage: Wordpress
#------------------------------------------------------------------------------
resource "random_password" "wordpressAdminPassword" {
  length           = 16
  special          = true
  override_special = "_%@"
  keepers = {
    version = "1"
  }
}

resource "random_password" "externalDatabasePassword" {
  length           = 16
  special          = true
  override_special = "_%@"
  keepers = {
    version = "1"
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

resource "kubernetes_namespace" "wordpress_namespace" {
  metadata {
    name = var.wordpress_namespace
  }
}

resource "kubernetes_secret" "wordpress" {
  metadata {
    name      = local.wordpress
    namespace = var.wordpress_namespace
  }
  data = {
    wordpress-password  = random_password.wordpressAdminPassword.result
    MYSQL_HOST          = data.kubernetes_secret.mysql_root.data.MYSQL_HOST
    MYSQL_PORT          = data.kubernetes_secret.mysql_root.data.MYSQL_PORT
    MYSQL_DATABASE      = local.externalDatabaseDatabase
    MYSQL_USERNAME      = local.externalDatabaseUser
    MYSQL_PASSWORD      = random_password.externalDatabasePassword.result
    REDIS_HOST          = data.kubernetes_secret.redis.data.REDIS_HOST
    REDIS_PORT          = local.externalCachePort
  }

  depends_on = [
    kubernetes_namespace.wordpress_namespace
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
