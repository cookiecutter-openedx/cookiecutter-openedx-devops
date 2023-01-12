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

resource "kubernetes_secret" "ssh_secret" {
  metadata {
    name      = "bastion-ssh-key"
    namespace = var.stack_namespace
  }

  # mcdaniel aug-2022: switch from DNS host name
  # to EC2 public ip address bc of occasional delays
  # in updates to Route53 DNS
  data = {
    HOST            = aws_eip.bastion.public_ip
    USER            = "ubuntu"
    PRIVATE_KEY_PEM = tls_private_key.bastion.private_key_pem
  }
}
