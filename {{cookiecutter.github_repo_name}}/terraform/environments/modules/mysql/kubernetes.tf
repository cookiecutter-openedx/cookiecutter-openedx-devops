#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: April 2022
#
# usage: create an RDS MySQL instance.
#        store the MySQL credentials in Kubernetes Secrets
#------------------------------------------------------------------------------
data "aws_eks_cluster" "eks" {
  name = var.resource_name
}

data "aws_eks_cluster_auth" "eks" {
  name = var.resource_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}


# Retrieve the mysql_root connection parameters from the shared resource namespace.
# we'll refer to this data for the HOST and PORT assignments on all of ther MySQL
# secrets.
data "kubernetes_secret" "mysql_root" {
  metadata {
    name      = "mysql-root"
    namespace = var.shared_resource_namespace
  }
}

resource "kubernetes_secret" "mysql_root" {
  metadata {
    name      = "mysql-root"
    namespace = var.namespace
  }

  data = {
    MYSQL_ROOT_USERNAME = data.kubernetes_secret.mysql_root.data.MYSQL_ROOT_USERNAME
    MYSQL_ROOT_PASSWORD = data.kubernetes_secret.mysql_root.data.MYSQL_ROOT_PASSWORD
    MYSQL_HOST          = data.kubernetes_secret.mysql_root.data.MYSQL_HOST
    MYSQL_PORT          = data.kubernetes_secret.mysql_root.data.MYSQL_PORT
  }
}

resource "random_password" "mysql_openedx" {
  length           = 16
  special          = true
  override_special = "_%@"
  keepers = {
    version = "1"
  }
}


resource "kubernetes_secret" "openedx" {
  metadata {
    name      = "mysql-openedx"
    namespace = var.namespace
  }

  data = {
    OPENEDX_MYSQL_DATABASE = substr("${var.db_prefix}_edx", -64, -1)
    OPENEDX_MYSQL_USERNAME = substr("${var.db_prefix}_edx", -32, -1)
    OPENEDX_MYSQL_PASSWORD = random_password.mysql_openedx.result
    MYSQL_HOST             = data.kubernetes_secret.mysql_root.data.MYSQL_HOST
    MYSQL_PORT             = data.kubernetes_secret.mysql_root.data.MYSQL_PORT
  }
}

resource "random_password" "mysql_discovery" {
  length           = 16
  special          = true
  override_special = "_%@"
  keepers = {
    version = "1"
  }
}

resource "kubernetes_secret" "discovery" {
  metadata {
    name      = "mysql-discovery"
    namespace = var.namespace
  }

  data = {
    DISCOVERY_MYSQL_DATABASE = substr("${var.db_prefix}_disc", -64, -1)
    DISCOVERY_MYSQL_USERNAME = substr("${var.db_prefix}_disc", -32, -1)
    DISCOVERY_MYSQL_PASSWORD = random_password.mysql_discovery.result
    MYSQL_HOST               = data.kubernetes_secret.mysql_root.data.MYSQL_HOST
    MYSQL_PORT               = data.kubernetes_secret.mysql_root.data.MYSQL_PORT
  }
}


resource "random_password" "mysql_ecommerce" {
  length           = 16
  special          = true
  override_special = "_%@"
  keepers = {
    version = "1"
  }
}

resource "kubernetes_secret" "ecommerce" {
  metadata {
    name      = "mysql-ecommerce"
    namespace = var.namespace
  }

  data = {
    ECOMMERCE_MYSQL_DATABASE = substr("${var.db_prefix}_ecom", -64, -1)
    ECOMMERCE_MYSQL_USERNAME = substr("${var.db_prefix}_ecom", -32, -1)
    ECOMMERCE_MYSQL_PASSWORD = random_password.mysql_ecommerce.result
    MYSQL_HOST               = data.kubernetes_secret.mysql_root.data.MYSQL_HOST
    MYSQL_PORT               = data.kubernetes_secret.mysql_root.data.MYSQL_PORT
  }
}


resource "random_password" "mysql_notes" {
  length           = 16
  special          = true
  override_special = "_%@"
  keepers = {
    version = "1"
  }
}

resource "kubernetes_secret" "notes" {
  metadata {
    name      = "mysql-notes"
    namespace = var.namespace
  }

  data = {
    NOTES_MYSQL_DATABASE = substr("${var.db_prefix}_notes", -64, -1)
    NOTES_MYSQL_USERNAME = substr("${var.db_prefix}_notes", -32, -1)
    NOTES_MYSQL_PASSWORD = random_password.mysql_notes.result
    MYSQL_HOST           = data.kubernetes_secret.mysql_root.data.MYSQL_HOST
    MYSQL_PORT           = data.kubernetes_secret.mysql_root.data.MYSQL_PORT
  }
}

resource "random_password" "mysql_xqueue" {
  length           = 16
  special          = true
  override_special = "_%@"
  keepers = {
    version = "1"
  }
}

resource "kubernetes_secret" "xqueue" {
  metadata {
    name      = "mysql-xqueue"
    namespace = var.namespace
  }

  data = {
    XQUEUE_MYSQL_DATABASE = substr("${var.db_prefix}_xq", -64, -1)
    XQUEUE_MYSQL_USERNAME = substr("${var.db_prefix}_xq", -32, -1)
    XQUEUE_MYSQL_PASSWORD = random_password.mysql_xqueue.result
    MYSQL_HOST            = data.kubernetes_secret.mysql_root.data.MYSQL_HOST
    MYSQL_PORT            = data.kubernetes_secret.mysql_root.data.MYSQL_PORT
  }
}

resource "random_password" "mysql_credentials" {
  length           = 16
  special          = true
  override_special = "_%@"
  keepers = {
    version = "1"
  }
}

resource "kubernetes_secret" "credentials" {
  metadata {
    name      = "mysql-credentials"
    namespace = var.namespace
  }

  data = {
    CREDENTIALS_MYSQL_DATABASE = substr("${var.db_prefix}_cred", -64, -1)
    CREDENTIALS_MYSQL_USERNAME = substr("${var.db_prefix}_cred", -32, -1)
    CREDENTIALS_MYSQL_PASSWORD = random_password.mysql_credentials.result
    MYSQL_HOST                 = data.kubernetes_secret.mysql_root.data.MYSQL_HOST
    MYSQL_PORT                 = data.kubernetes_secret.mysql_root.data.MYSQL_PORT
  }
}
