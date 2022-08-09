#------------------------------------------------------------------------------
#
# see: https://github.com/kubernetes-sigs/metrics-server
#
#------------------------------------------------------------------------------

#-----------------------------------------------------------
# NOTE: you must initialize a local helm repo in order to run
# this script.
#
#   brew install helm
#   helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
#   helm repo update
#
#-----------------------------------------------------------


resource "helm_release" "metrics_server" {
  namespace        = "metrics-server"
  create_namespace = true

  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "{{ cookiecutter.terraform_helm_metrics_server }}"

  depends_on = [
    module.eks
  ]
}
