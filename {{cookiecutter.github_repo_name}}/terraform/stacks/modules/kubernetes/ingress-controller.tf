#------------------------------------------------------------------------------
# written by:   Lawrence McDaniel
#               https://lawrencemcdaniel.com
#
# date:         oct-2022
#
# usage:        create a default cluster-wide nginx-ingress-controller
#               to be used by any ingress anywhere in the cluster
#               that does not explicitly specify a different class.
#
# see:          https://registry.terraform.io/modules/terraform-iaac/nginx-controller/helm/latest
#               https://kubernetes.github.io/ingress-nginx/user-guide/multiple-ingress/
#               https://github.com/kubernetes/ingress-nginx/issues/5593
#               https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-class
#------------------------------------------------------------------------------


resource "helm_release" "ingress-nginx-default" {
  name             = "default"
  namespace        = "kube-system"
  create_namespace = false

  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = "~> 4.2"

  set {
    name  = "service.type"
    value = "ClusterIP"
  }
  set {
    # see: https://github.com/kubernetes/ingress-nginx/issues/6100
    # mcdaniel: this value, "default" must equal that of the name field.
    name  = "controller.ingressClassResource.name"
    value = "default"
    type  = "string"
  }
  set {
    name  = "ingressclass.kubernetes.io/is-default-class"
    value = "true"
    type  = "string"
  }

  depends_on = [
    module.eks
  ]
}
