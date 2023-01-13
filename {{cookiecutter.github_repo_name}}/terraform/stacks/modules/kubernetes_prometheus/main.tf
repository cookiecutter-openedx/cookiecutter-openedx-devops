#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Aug-2022
#
# usage: installs Prometheus monitoring.
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
#
# NOTE: run `helm repo update` prior to running this
#       Terraform module.
#
# in the event of install problems, first try running these in
# order to elminate any existing CRDs:
#   kubectl delete crd alertmanagerconfigs.monitoring.coreos.com
#   kubectl delete crd alertmanagers.monitoring.coreos.com
#   kubectl delete crd podmonitors.monitoring.coreos.com
#   kubectl delete crd probes.monitoring.coreos.com
#   kubectl delete crd prometheuses.monitoring.coreos.com
#   kubectl delete crd prometheusrules.monitoring.coreos.com
#   kubectl delete crd servicemonitors.monitoring.coreos.com
#   kubectl delete crd thanosrulers.monitoring.coreos.com
#-----------------------------------------------------------

resource "random_password" "grafana" {
  length  = 16
  special = false
  keepers = {
    version = "1"
  }
}

resource "helm_release" "prometheus" {
  namespace        = "prometheus"
  create_namespace = true

  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "{{ cookiecutter.terraform_helm_prometheus }}"

  # changes the password (stored in k8s secret prometheus-grafana) from 'prom-operator'
  # to our own randomly generated 16-character strong password.
  set {
    name  = "grafana.adminPassword"
    value = random_password.grafana.result
  }

  # un-comment to include a yaml manifest with configuration overrides.
  # To generate a yaml file with all possible configuration options:
  #     helm show values prometheus-community/kube-prometheus-stack > ./yml/values.yaml
  #
  #values = [
  #  "${file("${path.module}/yml/values.yaml")}"
  #]

}
