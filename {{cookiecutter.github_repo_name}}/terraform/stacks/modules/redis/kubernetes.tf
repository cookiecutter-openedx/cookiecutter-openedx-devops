#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create an ElastiCache Redis cache
#        stored cache credentials in Kubernetes Secrets.
#------------------------------------------------------------------------------
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

resource "kubernetes_secret" "secret" {
  metadata {
    name      = "redis"
    namespace = var.environment_namespace
  }

  data = {
    REDIS_HOST = module.redis.primary_endpoint_address
  }
}
