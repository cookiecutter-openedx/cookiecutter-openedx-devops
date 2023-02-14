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

resource "random_password" "wordpressPassword" {
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

data "template_file" "resource_quota" {
  template = file("${path.module}/config/resource-quota.yaml.tpl")
  vars = {
    namespace             = local.wordpressNamespace
    resource_quota_cpu    = var.resource_quota_cpu
    resource_quota_memory = var.resource_quota_memory
  }
}

resource "kubectl_manifest" "resource_quota" {
  count     = var.resource_quota == "Y" ? 1 : 0
  yaml_body = data.template_file.resource_quota.rendered

  depends_on = [
    kubernetes_secret.wordpress_config,
    ssh_sensitive_resource.mysql,
    kubernetes_namespace.wordpress,
    helm_release.wordpress
  ]
}

resource "kubernetes_secret" "wordpress_config" {
  metadata {
    name      = "wordpress-config"
    namespace = local.wordpressNamespace
  }
  data = {
    wordpress-username = local.wordpressUsername
    wordpress-password = random_password.wordpressPassword.result
    mariadb-password   = random_password.externalDatabasePassword.result
    MYSQL_HOST         = data.kubernetes_secret.mysql_root.data.MYSQL_HOST
    MYSQL_PORT         = data.kubernetes_secret.mysql_root.data.MYSQL_PORT
    MYSQL_DATABASE     = local.externalDatabaseDatabase
    MYSQL_USERNAME     = local.externalDatabaseUser
    MYSQL_PASSWORD     = random_password.externalDatabasePassword.result
    REDIS_HOST         = data.kubernetes_secret.redis.data.REDIS_HOST
    REDIS_PORT         = local.externalCachePort
  }

  depends_on = [
    kubernetes_namespace.wordpress,
    ssh_sensitive_resource.mysql
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
