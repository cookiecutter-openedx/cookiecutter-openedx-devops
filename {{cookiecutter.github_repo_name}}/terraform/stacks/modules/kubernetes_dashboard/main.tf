#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: installs Kubernetes Dashboard web application
# see: https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
#      https://blog.heptio.com/on-securing-the-kubernetes-dashboard-16b09b1b7aca
#
# to run:
#   in a separate terminal window run:  kubectl proxy
#   in a browser window run: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
#
#   The login page will ask for a token. To generate said token, run:
#   kubectl -n kubernetes-dashboard create token kubernetes-dashboard
#
# helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
# helm install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard
# helm search repo kubernetes-dashboard
# helm show values kubernetes-dashboard/kubernetes-dashboard
#
# Get the Kubernetes Dashboard URL by running:
#   export POD_NAME=$(kubectl get pods -n default -l "app.kubernetes.io/name=kubernetes-dashboard,app.kubernetes.io/instance=kubernetes-dashboard" -o jsonpath="{.items[0].metadata.name}")
#   echo https://127.0.0.1:8443/
#   kubectl -n default port-forward $POD_NAME 8443:8443
#-----------------------------------------------------------
locals {
  tags = merge(
    var.tags,
    module.cookiecutter_meta.tags,
    {
      "cookiecutter/module/source"    = "{{ cookiecutter.github_repo_name }}/terraform/stacks/modules/kubernetes_dashboard"
      "cookiecutter/resource/source"  = "kubernetes.github.io/dashboard"
      "cookiecutter/resource/version" = "{{ cookiecutter.terraform_helm_dashboard }}"
    }
  )
}

data "template_file" "dashboard-values" {
  template = file("${path.module}/yml/values.yaml")
}

resource "helm_release" "dashboard" {
  name             = "common"
  namespace        = "kubernetes-dashboard"
  create_namespace = true

  chart      = "kubernetes-dashboard"
  repository = "https://kubernetes.github.io/dashboard/"
  version    = "~> {{ cookiecutter.terraform_helm_dashboard }}"

  values = [
    data.template_file.dashboard-values.rendered
  ]
}

#------------------------------------------------------------------------------
#                               COOKIECUTTER META
#------------------------------------------------------------------------------
module "cookiecutter_meta" {
  source = "../../../../../../../common/cookiecutter_meta"
}

resource "kubernetes_secret" "cookiecutter" {
  metadata {
    name      = "cookiecutter"
    namespace = var.cert_manager_namespace
  }

  # https://stackoverflow.com/questions/64134699/terraform-map-to-string-value
  data = {
    tags = jsonencode(local.tags)
  }
}
