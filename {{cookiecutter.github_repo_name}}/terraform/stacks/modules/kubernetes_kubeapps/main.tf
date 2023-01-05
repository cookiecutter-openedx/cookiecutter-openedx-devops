#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Jan-2023
#
# usage: installs kubeapps
# see: https://kubeapps.dev/docs/latest/tutorials/getting-started/
#
# requirements: you must initialize a local helm repo in order to run
# this mdoule.
#
#   brew install helm
#   helm repo add bitnami https://charts.bitnami.com/bitnami
#   helm repo update
#   helm search repo bitnami/kubeapps
#
# NOTE: run `helm repo update` prior to running this
#       Terraform module.
#-----------------------------------------------------------
locals {
  kubeapps_namespace        = "kubeapps"
  kubeapps_account_name     = "kubeapps-admin"
  kubeapps_ingress_hostname = "${local.kubeapps_namespace}.${var.environment_domain}"
}

resource "kubernetes_namespace" "kubeapps" {
  metadata {
    name = local.kubeapps_namespace
  }
}

resource "helm_release" "kubeapps" {
  namespace        = local.kubeapps_namespace
  create_namespace = true

  name       = "kubeapps"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "kubeapps"

  # see https://docs.bitnami.com/kubernetes/infrastructure/kubeapps/configuration/expose-service/
  set {
    name  = "ingress.enabled"
    value = false
  }

  # set {
  #   name  = "ingress.hostname"
  #   value = local.kubeapps_ingress_hostname
  # }

  depends_on = [
    kubernetes_namespace.kubeapps
  ]
}

resource "kubernetes_service_account" "kubeapps_admin" {
  metadata {
    name      = local.kubeapps_account_name
    namespace = local.kubeapps_namespace
  }

  depends_on = [
    helm_release.kubeapps,
    kubernetes_service_account.kubeapps_admin,
  ]
}

resource "kubernetes_cluster_role_binding" "kubeapps_admin" {
  metadata {
    name = kubernetes_namespace.kubeapps.metadata.0.name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.kubeapps_admin.metadata.0.name
    namespace = kubernetes_namespace.kubeapps.metadata.0.name
  }
  subject {
    kind      = "Group"
    name      = "system:masters"
    api_group = "rbac.authorization.k8s.io"
  }

  depends_on = [
    helm_release.kubeapps,
    kubernetes_service_account.kubeapps_admin,
  ]
}


resource "kubernetes_secret_v1" "kubeapps_admin" {
  metadata {
    name      = local.kubeapps_account_name
    namespace = kubernetes_namespace.kubeapps.metadata.0.name
    annotations = {
      "kubernetes.io/service-account.name"      = local.kubeapps_account_name
      "kubernetes.io/service-account.namespace" = local.kubeapps_namespace
    }
  }

  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = false

  depends_on = [
    helm_release.kubeapps,
    kubernetes_service_account.kubeapps_admin,
  ]
}

resource "kubectl_manifest" "ingress-kubeapps" {
  yaml_body = file("${path.module}/yml/ingress-kubeapps.yml")

  depends_on = [
    helm_release.kubeapps,
    kubernetes_namespace.kubeapps
  ]
}
