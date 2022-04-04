#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2022
#
# usage: store MongoDB credentials in EKS Cluster Kubernetes Secrets
#------------------------------------------------------------------------------
locals {

  mongo_host = "${aws_route53_record.master.name}.${var.environment_domain}"

}


data "aws_eks_cluster" "eks" {
  name = var.environment_namespace
}

data "aws_eks_cluster_auth" "eks" {
  name = var.environment_namespace
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

resource "random_password" "mongodb_admin" {
  length           = 16
  special          = false
  override_special = "_%@"
  keepers = {
    version = "1"
  }
}

resource "kubernetes_secret" "mongodb_admin" {
  metadata {
    name      = "mongodb-admin"
    namespace = "openedx"
  }

  data = {
    MONGODB_HOST     = local.mongo_host
    MONGODB_PORT     = var.db_port
    MONGODB_USERNAME = aws_docdb_cluster.default.master_username
    MONGODB_PASSWORD = random_password.mongodb_admin.result
  }
}
