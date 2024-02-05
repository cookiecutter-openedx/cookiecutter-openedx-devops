#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Jan-2023
#------------------------------------------------------------------------------

resource "kubernetes_namespace" "kubeapps" {
  metadata {
    name = local.kubeapps_namespace
  }
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

resource "kubernetes_manifest" "ingress-kubeapps" {
  manifest = yamldecode(templatefile("${path.module}/yml/ingress-kubeapps.yml", {}))

  depends_on = [
    helm_release.kubeapps,
    kubernetes_namespace.kubeapps
  ]
}
