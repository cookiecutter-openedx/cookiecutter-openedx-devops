#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: add a Kubernetes ingress ALB controller.
#
# see:
# - https://github.com/aws/eks-charts/tree/master/stable/aws-load-balancer-controller#configuration
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# written by: Benjamin P. Jung
#             headcr4sh@gmail.com
#
#             U.S. General Services Administration
#             https://open.gsa.gov
#             https://github.com/GSA/terraform-kubernetes-aws-load-balancer-controller
#             forked from : https://registry.terraform.io/modules/iplabs/alb-ingress-controller/kubernetes/latest
#
# mcdaniel mar-2022:
# i've seen this same code in many other places, but this is the only set that
# actually worked, and it looks like its being actively maintained by GSA.
# The latter half of this article, written by Harshet Jain, provides a
# good explanation of how this works:
# https://betterprogramming.pub/with-latest-updates-create-amazon-eks-fargate-cluster-and-managed-node-group-using-terraform-bc5cfefd5773
#------------------------------------------------------------------------------
module "alb_controller" {
  source                                     = "github.com/GSA/terraform-kubernetes-aws-load-balancer-controller"
  aws_load_balancer_controller_chart_version = "{{ cookiecutter.terraform_helm_alb_conroller }}"

  providers = {
    kubernetes = kubernetes.eks,
    helm       = helm.eks
  }

  k8s_cluster_type          = "eks"
  k8s_cluster_name          = var.environment_namespace
  k8s_namespace             = "kube-system"
  k8s_replicas              = 1
  aws_iam_path_prefix       = ""
  aws_vpc_id                = var.vpc_id
  aws_region_name           = var.aws_region
  aws_resource_name_prefix  = ""
  aws_tags                  = var.tags
  alb_controller_depends_on = [module.eks]
  enable_host_networking    = false

  # custom configuration data
  k8s_pod_annotations = {}
  k8s_pod_labels      = {}
  chart_env_overrides = {}
  target_groups       = []
}
