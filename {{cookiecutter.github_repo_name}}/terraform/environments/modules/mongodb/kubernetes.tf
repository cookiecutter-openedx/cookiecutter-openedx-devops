#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: aug-2022
#
# usage: create environment connection resources for remote MongoDB instance.
#        store the MongoDB credentials in Kubernetes Secrets
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


# Retrieve the mongodb_admin connection parameters from the shared resource namespace.
# we'll refer to this data for the HOST and PORT assignments on all other MySQL
# secrets.
data "kubernetes_secret" "mongodb_admin" {
  metadata {
    name      = "mongodb-admin"
    namespace = var.shared_resource_namespace
  }
}

resource "kubernetes_secret" "mongodb_admin" {
  metadata {
    name      = "mongodb-admin"
    namespace = var.environment_namespace
  }

  data = {
    MONGODB_ADMIN_USERNAME = data.kubernetes_secret.mongodb_admin.data.MONGODB_ADMIN_USERNAME
    MONGODB_ADMIN_PASSWORD = data.kubernetes_secret.mongodb_admin.data.MONGODB_ADMIN_PASSWORD
    MONGODB_HOST           = data.kubernetes_secret.mongodb_admin.data.MONGODB_HOST
    MONGODB_PORT           = data.kubernetes_secret.mongodb_admin.data.MONGODB_PORT
  }
}

resource "random_password" "mongodb_openedx" {
  length           = 16
  special          = true
  override_special = "_%@"
  keepers = {
    version = "1"
  }
}

# not currently using authentication for mongodb, which
# is the same default treatment as with tutor.
resource "kubernetes_secret" "openedx" {
  metadata {
    name      = "mongodb-openedx"
    namespace = var.environment_namespace
  }

  data = {
    MONGODB_DATABASE = substr("${var.db_prefix}_edx", -32, -1)
    #MONGODB_USERNAME = substr("${var.db_prefix}_edx", -32, -1)
    #MONGODB_PASSWORD = random_password.mongodb_openedx.result
    MONGODB_USERNAME = ""
    MONGODB_PASSWORD = ""
    MONGODB_HOST     = data.kubernetes_secret.mongodb_admin.data.MONGODB_HOST
    MONGODB_PORT     = data.kubernetes_secret.mongodb_admin.data.MONGODB_PORT
  }
}
