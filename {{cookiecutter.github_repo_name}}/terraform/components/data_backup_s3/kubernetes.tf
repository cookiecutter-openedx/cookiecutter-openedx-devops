#------------------------------------------------------------------------------ 
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create a non-public S3 Bucket to store data backups from any backend 
#        service.
#
#        store S3 credentials (key/secret pair) in EKS Kubernetes Secrets.
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

resource "kubernetes_secret" "s3" {
  metadata {
    name      = var.secret_name
    namespace = var.environment_namespace
  }

  data = {
    AWS_ACCESS_KEY_ID     = aws_iam_access_key.user.id
    AWS_SECRET_ACCESS_KEY = aws_iam_access_key.user.secret
    S3_BUCKET             = module.data_backup_s3_bucket.s3_bucket_id
  }
}
