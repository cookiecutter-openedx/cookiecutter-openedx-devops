#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: Feb-2023
#
# usage: Wordpress Kubernetes secretes
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
