#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: use Helm to add a Kubernetes ingress ALB controller
#        using the AWS-sponsored helm chart
#
# see:
# - https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/
# - https://github.com/aws/eks-charts/tree/master/stable/aws-load-balancer-controller
# - https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/
#
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
  aws_load_balancer_controller_chart_version = "{{ cookiecutter.terraform_helm_alb_controller }}"

  k8s_cluster_type          = "eks"
  k8s_cluster_name          = var.environment_namespace
  k8s_namespace             = "alb"
  k8s_replicas              = 2
  aws_iam_path_prefix       = ""
  aws_vpc_id                = var.vpc_id
  aws_region_name           = var.aws_region
  aws_resource_name_prefix  = ""
  aws_tags                  = var.tags
  alb_controller_depends_on = [data.aws_eks_cluster.cluster]
  enable_host_networking    = false
  k8s_pod_labels            = {}
  chart_env_overrides       = {}
  target_groups             = []

  # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/guide/ingress/annotations/
  # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.1/guide/ingress/cert_discovery/
  # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.1/guide/integrations/external_dns/
  #
  # mcdaniel: automatic cert discovery is enabled by **NOT** including alb.ingress.kubernetes.io/certificate-arn
  k8s_pod_annotations = {
    "alb.ingress.kubernetes.io/load-balancer-name" : "${var.environment_namespace}",
    "alb.ingress.kubernetes.io/ip-address-type" : "ipv4"
    "alb.ingress.kubernetes.io/scheme" : "internet-facing",
    "alb.ingress.kubernetes.io/security-groups" : aws_security_group.sg_alb.name,
    "alb.ingress.kubernetes.io/load-balancer-attributes" : "",
    "alb.ingress.kubernetes.io/listen-ports" : jsonencode([{ "HTTP" : 80 }, { "HTTPS" : 443 }, { "HTTP" : 8080 }, { "HTTPS" : 8443 }]),
    "alb.ingress.kubernetes.io/ssl-redirect" : "443",
    "alb.ingress.kubernetes.io/target-type" : "ip",
    "alb.ingress.kubernetes.io/backend-protocol" : "HTTP",
    "alb.ingress.kubernetes.io/target-group-attributes" : "",
    "alb.ingress.kubernetes.io/healthcheck-port" : "80",
    "alb.ingress.kubernetes.io/healthcheck-path" : "/",
    "alb.ingress.kubernetes.io/healthcheck-interval-seconds" : "15",
    "alb.ingress.kubernetes.io/healthcheck-timeout-seconds" : "5",
    "alb.ingress.kubernetes.io/healthy-threshold-count" : "2",
    "alb.ingress.kubernetes.io/unhealthy-threshold-count" : "2",
    "alb.ingress.kubernetes.io/success-codes" : "200",
    "alb.ingress.kubernetes.io/target-node-labels" : "label1=openedx"
    "external-dns.alpha.kubernetes.io/hostname" : "${var.environment_domain}"
    "external-dns.alpha.kubernetes.io/hostname" : "*.${var.environment_domain}"
  }

}
