#------------------------------------------------------------------------------ 
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create an AWS S3 bucket to offload Open edX file storage.
#        store S3 credentials in Kubernetes Secrets.
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
    OPENEDX_AWS_ACCESS_KEY        = aws_iam_access_key.user.id
    OPENEDX_AWS_SECRET_ACCESS_KEY = aws_iam_access_key.user.secret
    S3_STORAGE_BUCKET             = module.data_backup_s3_bucket.s3_bucket_id
    S3_REGION                     = var.aws_region
    S3_CUSTOM_DOMAIN              = "cdn.${var.environment_domain}"
  }
}
