#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: Add nginx proxy for EKS cluster load balancer
#
# see:
# - https://kubernetes.github.io/ingress-nginx/
# - https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/
#------------------------------------------------------------------------------
resource "helm_release" "ingress-nginx" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true

  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = "{{ cookiecutter.terraform_helm_ingress_nginx }}"

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  depends_on = [
    module.eks,
    aws_kms_key.eks
  ]
}
