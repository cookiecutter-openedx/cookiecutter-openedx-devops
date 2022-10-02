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
# see:          https://github.com/kubernetes/ingress-nginx/issues/5593
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
  # see: https://github.com/kubernetes/ingress-nginx/issues/6100
  # mcdaniel: the helm chart tries to set this to the value, "nginx"
  #           which would cause name collision problems in the event
  #           that we wanted to add multiple ingress controllers for
  #           scaling purposes. we therefore force the ingressClass
  #           name to match the value of the name of the controller, "default".
  set {
    name  = "controller.ingressClassResource.name"
    value = "default"
    type  = "string"
  }
  # mcdaniel: setting this nginx ingress controller to be
  #           the "default" controller means that all ingress
  #           objects will, by default, create their nginx
  #           virtual server on THIS nginx instance regardless
  #           of what other nginx servers might exist on this
  #           cluster.
  # see: https://kubernetes.github.io/ingress-nginx/user-guide/multiple-ingress/
  set {
    name  = "ingressclass.kubernetes.io/is-default-class"
    value = "true"
    type  = "string"
  }

  depends_on = [
    module.eks
  ]
}
