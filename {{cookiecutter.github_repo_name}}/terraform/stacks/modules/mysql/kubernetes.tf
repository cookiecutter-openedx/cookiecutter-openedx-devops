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

resource "kubernetes_secret" "mysql_root" {
  metadata {
    name      = "mysql-root"
    namespace = var.resource_name
  }

  data = {
    MYSQL_ROOT_USERNAME = module.db.db_instance_username
    MYSQL_ROOT_PASSWORD = module.db.db_instance_password
    MYSQL_HOST          = module.db.db_instance_address
    MYSQL_PORT          = module.db.db_instance_port
  }
}
