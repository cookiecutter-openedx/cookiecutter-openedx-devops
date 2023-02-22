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
#
# helm reference:
#   brew install helm
#
#   helm repo add ingress-nginx https://github.com/kubernetes/ingress-nginx
#   helm repo update
#   helm show all ingress-nginx/ingress-nginx
#   helm show values ingress-nginx/ingress-nginx

#------------------------------------------------------------------------------

data "template_file" "nginx-values" {
  template = file("${path.module}/yml/nginx-values.yaml")
}

resource "helm_release" "ingress_nginx_controller" {
  name             = "common"
  namespace        = var.namespace
  create_namespace = false

  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = "{{ cookiecutter.terraform_helm_ingress_nginx_controller }}"

  values = [
    data.template_file.nginx-values.rendered
  ]

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

}
