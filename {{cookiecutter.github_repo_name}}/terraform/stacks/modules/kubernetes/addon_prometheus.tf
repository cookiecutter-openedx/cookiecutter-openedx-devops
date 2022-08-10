#------------------------------------------------------------------------------
#
# see:  https://prometheus.io/
#       https://grafana.com/
#       https://prometheus-operator.dev/docs/prologue/quick-start/
#
# requirements: you must initialize a local helm repo in order to run
# this mdoule.
#
#   brew install helm
#   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts/
#   helm repo update
#   helm search repo prometheus-community
#
# Configuration: all configurations options are located in ./yml/kube-prometheus-config.yaml
#   you can update the contents of this yaml file by running the following:
#
#   helm show values prometheus-community/kube-prometheus-stack
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

  values = [
    "${file("${path.module}/yml/kube-prometheus-config.yaml")}"
  ]


  depends_on = [
    module.eks,
  ]
}
