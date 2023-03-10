#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: build an EKS cluster load balancer
#------------------------------------------------------------------------------

data "aws_eks_cluster" "eks" {
  name = var.shared_resource_namespace
}

data "aws_eks_cluster" "cluster" {
  name = var.shared_resource_namespace
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.shared_resource_namespace
}

data "kubernetes_service" "ingress_nginx_controller" {
  metadata {
    name      = "common-ingress-nginx-controller"
    namespace = "kube-system"
  }
}

data "aws_elb_hosted_zone_id" "main" {}
