data "aws_eks_cluster" "eks" {
  name = var.kubernetes_name
}

data "aws_eks_cluster_auth" "eks" {
  name = var.kubernetes_name
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
    S3_STORAGE_BUCKET             = module.openedx_storage.s3_bucket_id
    S3_BACKUP_BUCKET              = module.openedx_backup.s3_bucket_id
    S3_REGION                     = var.aws_region
    S3_CUSTOM_DOMAIN              = "cdn.${var.environment_domain}"
  }
}
