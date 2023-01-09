#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Jan-2023
#
# usage: installs Kubernetes Dashboard web application
# see: https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
#      https://stackoverflow.com/questions/46664104/how-to-sign-in-kubernetes-dashboard
#
# requirements:
#   helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
#   helm repo update
#-----------------------------------------------------------
locals {
}


resource "kubernetes_namespace" "dashboard" {
  metadata {
    name = var.dashboard_namespace
  }
}

resource "helm_release" "kubernetes-dashboard" {
  namespace        = var.dashboard_namespace
  create_namespace = false

  # see https://artifacthub.io/packages/helm/k8s-dashboard/kubernetes-dashboard
  name       = "kubernetes-dashboard"
  repository = "https://kubernetes.github.io/dashboard/"
  chart      = "kubernetes-dashboard"
  version    = "6.0.0"

  # see https://docs.bitnami.com/kubernetes/infrastructure/dashboard/configuration/expose-service/
  set {
    name  = "service.externalPort"
    value = 80
  }

  set {
    name  = "protocolHttp"
    value = true
  }

  set {
    name  = "serviceAccount.create"
    value = false
  }

  set {
    name  = "serviceAccount.name"
    value = var.dashboard_account_name
  }

  set {
    name  = "rbac.create"
    value = false
  }

  depends_on = [
    kubernetes_namespace.dashboard
  ]
}

resource "kubernetes_service_account" "dashboard_admin" {
  metadata {
    name      = var.dashboard_account_name
    namespace = var.dashboard_namespace
  }
}

resource "kubernetes_cluster_role_binding" "dashboard_admin" {
  metadata {
    name = kubernetes_service_account.dashboard_admin.metadata.0.name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.dashboard_admin.metadata.0.name
    namespace = kubernetes_namespace.dashboard.metadata.0.name
  }
  subject {
    kind      = "Group"
    name      = "system:masters"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubectl_manifest" "ingress-dashboard" {
  yaml_body = file("${path.module}/yml/ingress-dashboard.yml")
}
