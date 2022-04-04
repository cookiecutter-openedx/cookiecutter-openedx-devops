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
    namespace = "openedx"
  }

  data = {
    OPENEDX_AWS_ACCESS_KEY        = aws_iam_access_key.user.id
    OPENEDX_AWS_SECRET_ACCESS_KEY = aws_iam_access_key.user.secret
    S3_STORAGE_BUCKET             = module.data_backup_s3_bucket.s3_bucket_id
    S3_REGION                     = var.aws_region
    S3_CUSTOM_DOMAIN              = "cdn.${var.environment_domain}"
  }
}
