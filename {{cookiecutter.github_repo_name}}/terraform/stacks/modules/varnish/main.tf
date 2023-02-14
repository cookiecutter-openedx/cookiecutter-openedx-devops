#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: installs IBM Varnish Operator
# see: https://ibm.github.io/varnish-operator/quick-start.html
#
# requirements: you must initialize a local helm repo in order to run
# this mdoule.
#
#   brew install helm
#   helm repo add varnish-operator https://raw.githubusercontent.com/IBM/varnish-operator/main/helm-releases
#   helm repo update
#   helm search repo varnish-operator
#   helm show values varnish-operator/varnish-operator
#
# NOTE: run `helm repo update` prior to running this
#       Terraform module.
#-----------------------------------------------------------

resource "helm_release" "varnish_operator" {
  namespace        = "varnish-operator"
  create_namespace = true

  name       = "varnish-operator"
  repository = "https://raw.githubusercontent.com/IBM/varnish-operator/main/helm-releases"
  chart      = "varnish-operator"
  version    = "~> 0.35"

}


#------------------------------------------------------------------------------
# Tutor deploys into this namespace, bc of a namesapce command-line argument
# that we pass inside of GitHub Actions deploy workflow
#------------------------------------------------------------------------------
resource "kubernetes_namespace" "varnish_cluster" {
  metadata {
    name = "varnish-cluster"
  }
}

data "template_file" "varnish_cluster" {
  template = file("${path.module}/config/varnish-cluster.yaml.tpl")
  vars = {
    namespace = "varnish-cluster"
  }
}

resource "kubectl_manifest" "varnish_cluster" {
  yaml_body = data.template_file.varnish_cluster.rendered

  depends_on = [
    kubernetes_namespace.varnish_cluster,
    helm_release.varnish_operator
  ]
}
