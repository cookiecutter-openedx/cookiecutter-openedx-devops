#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage:
#
# see:
#   https://github.com/GSA/terraform-kubernetes-aws-load-balancer-controller
#------------------------------------------------------------------------------

module "alb_controller" {
  source = "github.com/GSA/terraform-kubernetes-aws-load-balancer-controller"
  #version = "v5.0.1"

  providers = {
    kubernetes = kubernetes.eks,
    helm       = helm.eks
  }

  k8s_cluster_type = "eks"
  k8s_namespace    = "kube-system"

  aws_region_name  = var.aws_region
  k8s_cluster_name = data.aws_eks_cluster.cluster.name

  alb_controller_depends_on = [module.eks]
}
