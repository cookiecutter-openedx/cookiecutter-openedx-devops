#------------------------------------------------------------------------------
#
# see: https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack
#
# usage:
#   helm install [RELEASE_NAME] prometheus-community/kube-prometheus-stack
#
# requirements: you must initialize a local helm repo in order to run
# this mdoule.
#
#   brew install helm
#   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts/
#   helm repo update
#   helm search repo prometheus-community
#
# NOTE: run `helm repo update` prior to running this
#       Terraform module.
#-----------------------------------------------------------

resource "helm_release" "prometheus" {
  namespace        = "monitoring"
  create_namespace = true

  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "{{ cookiecutter.terraform_helm_kube_prometheus }}"

  depends_on = [
    module.eks,
  ]
}
