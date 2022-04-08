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

resource "kubernetes_secret" "mysql_root" {
  metadata {
    name      = "mysql-root"
    namespace = "openedx"
  }

  data = {
    MYSQL_ROOT_USERNAME = module.db.db_instance_username
    MYSQL_ROOT_PASSWORD = module.db.db_instance_password
    MYSQL_HOST          = aws_route53_record.mysql.fqdn
    MYSQL_PORT          = module.db.db_instance_port
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
    namespace = "openedx"
  }

  data = {
    OPENEDX_MYSQL_USERNAME = "openedx"
    OPENEDX_MYSQL_PASSWORD = random_password.mysql_openedx.result
    MYSQL_HOST             = aws_route53_record.mysql.fqdn
    MYSQL_PORT             = module.db.db_instance_port
  }
}
