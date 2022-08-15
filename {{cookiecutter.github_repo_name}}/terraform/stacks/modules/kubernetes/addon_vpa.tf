#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Aug-2022
#
# usage: installs the Kubernetes Vertical Pod Autoscaler.
#
# see:  https://www.datree.io/helm-chart/vertical-pod-autoscaler-helm
#       https://www.youtube.com/watch?v=jcHQ5SKKTLM
#
# requirements: you must initialize a local helm repo in order to run
# this mdoule.
#
#   brew install helm
#   helm repo add cowboysysop https://cowboysysop.github.io/charts/
#   helm repo update
#   helm search repo cowboysysop
#
#
# NOTE: run `helm repo update` prior to running this
#       Terraform module.
#-----------------------------------------------------------
resource "helm_release" "vpa" {
  namespace        = "monitoring"
  create_namespace = true

  name       = "vertical-pod-autoscaler"
  repository = "https://cowboysysop.github.io/charts/"
  chart      = "vertical-pod-autoscaler"
  version    = "5.1.1"

  depends_on = [
    module.eks,
  ]
}

resource "kubectl_manifest" "vpa-lms" {
  yaml_body = file("${path.module}/yml/vpa-lms.yaml")

  depends_on = [
    module.eks,
    helm_release.vpa
  ]
}

resource "kubectl_manifest" "vpa-lms-worker" {
  yaml_body = file("${path.module}/yml/vpa-lms-worker.yaml")

  depends_on = [
    module.eks,
    helm_release.vpa
  ]
}

resource "kubectl_manifest" "vpa-cms" {
  yaml_body = file("${path.module}/yml/vpa-cms.yaml")

  depends_on = [
    module.eks,
    helm_release.vpa
  ]
}

resource "kubectl_manifest" "vpa-cms-worker" {
  yaml_body = file("${path.module}/yml/vpa-cms-worker.yaml")

  depends_on = [
    module.eks,
    helm_release.vpa
  ]
}

resource "kubectl_manifest" "vpa-mfe" {
  yaml_body = file("${path.module}/yml/vpa-mfe.yaml")

  depends_on = [
    module.eks,
    helm_release.vpa
  ]
}

resource "kubectl_manifest" "vpa-elasticsearch" {
  yaml_body = file("${path.module}/yml/vpa-elasticsearch.yaml")

  depends_on = [
    module.eks,
    helm_release.vpa
  ]
}

resource "kubectl_manifest" "vpa-discovery" {
  yaml_body = file("${path.module}/yml/vpa-discovery.yaml")

  depends_on = [
    module.eks,
    helm_release.vpa
  ]
}

resource "kubectl_manifest" "mongodb" {
  yaml_body = file("${path.module}/yml/vpa-mongodb.yaml")

  depends_on = [
    module.eks,
    helm_release.vpa
  ]
}
