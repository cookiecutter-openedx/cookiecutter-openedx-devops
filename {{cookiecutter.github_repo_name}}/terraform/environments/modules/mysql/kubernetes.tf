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


# Retrieve the mysql_root connection parameters from openedx-shared namespace.
# we'll refer to this data for the HOST and PORT assignments on all of ther MySQL
# secrets.
data "kubernetes_secret" "mysql_root" {
  metadata {
    name      = "mysql-root"
    namespace = "openedx-shared"
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
    OPENEDX_MYSQL_USERNAME = "${var.environment}-openedx"
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
    DISCOVERY_MYSQL_USERNAME = "${var.environment}-discovery"
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
    ECOMMERCE_MYSQL_USERNAME = "${var.environment}-ecommerce"
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
    NOTES_MYSQL_USERNAME = "${var.environment}-notes"
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
    XQUEUE_MYSQL_USERNAME = "${var.environment}-xqueue"
    XQUEUE_MYSQL_PASSWORD = random_password.mysql_xqueue.result
    MYSQL_HOST            = data.kubernetes_secret.mysql_root.data.MYSQL_HOST
    MYSQL_PORT            = data.kubernetes_secret.mysql_root.data.MYSQL_PORT
  }
}
