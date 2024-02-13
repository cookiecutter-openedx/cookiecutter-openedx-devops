locals {

  vpa_cms = templatefile("${path.module}/yml/verticalpodautoscalers/vpa-openedx-cms.yaml.tpl", {
    environment_namespace = var.environment_namespace
  })

  vpa_cms_worker = templatefile("${path.module}/yml/verticalpodautoscalers/vpa-openedx-cms-worker.yaml.tpl", {
    environment_namespace = var.environment_namespace
  })

  vpa_discovery = templatefile("${path.module}/yml/verticalpodautoscalers/vpa-openedx-discovery.yaml.tpl", {
    environment_namespace = var.environment_namespace
  })

  vpa_elasticsearch = templatefile("${path.module}/yml/verticalpodautoscalers/vpa-openedx-elasticsearch.yaml.tpl", {
    environment_namespace = var.environment_namespace
  })

  vpa_lms = templatefile("${path.module}/yml/verticalpodautoscalers/vpa-openedx-lms.yaml.tpl", {
    environment_namespace = var.environment_namespace
  })

  vpa_lms_worker = templatefile("${path.module}/yml/verticalpodautoscalers/vpa-openedx-lms-worker.yaml.tpl", {
    environment_namespace = var.environment_namespace
  })

  vpa_mfe = templatefile("${path.module}/yml/verticalpodautoscalers/vpa-openedx-mfe.yaml.tpl", {
    environment_namespace = var.environment_namespace
  })

  vpa_mongodb = templatefile("${path.module}/yml/verticalpodautoscalers/vpa-openedx-mongodb.yaml.tpl", {
    environment_namespace = var.environment_namespace
  })

  vpa_notes = templatefile("${path.module}/yml/verticalpodautoscalers/vpa-openedx-notes.yaml.tpl", {
    environment_namespace = var.environment_namespace
  })

  vpa_smtp = templatefile("${path.module}/yml/verticalpodautoscalers/vpa-openedx-smtp.yaml.tpl", {
    environment_namespace = var.environment_namespace
  })


}

resource "kubernetes_manifest" "vpa-lms" {
  manifest = yamldecode(local.vpa_lms)

  depends_on = [
    kubernetes_namespace.environment_namespace
  ]
}

resource "kubernetes_manifest" "vpa-lms-worker" {
  manifest = yamldecode(local.vpa_lms_worker)

  depends_on = [
    kubernetes_namespace.environment_namespace
  ]
}


resource "kubernetes_manifest" "vpa-cms" {
  manifest = yamldecode(local.vpa_cms)

  depends_on = [
    kubernetes_namespace.environment_namespace
  ]
}

resource "kubernetes_manifest" "vpa-cms-worker" {
  manifest = yamldecode(local.vpa_cms_worker)

  depends_on = [
    kubernetes_namespace.environment_namespace
  ]
}

resource "kubernetes_manifest" "vpa-mfe" {
  manifest = yamldecode(local.vpa_mfe)

  depends_on = [
    kubernetes_namespace.environment_namespace
  ]
}

resource "kubernetes_manifest" "vpa-elasticsearch" {
  manifest = yamldecode(local.vpa_elasticsearch)

  depends_on = [
    kubernetes_namespace.environment_namespace
  ]
}

resource "kubernetes_manifest" "vpa-discovery" {
  manifest = yamldecode(local.vpa_discovery)

  depends_on = [
    kubernetes_namespace.environment_namespace
  ]
}

resource "kubernetes_manifest" "mongodb" {
  manifest = yamldecode(local.vpa_mongodb)

  depends_on = [
    kubernetes_namespace.environment_namespace
  ]
}

resource "kubernetes_manifest" "notes" {
  manifest = yamldecode(local.vpa_notes)

  depends_on = [
    kubernetes_namespace.environment_namespace
  ]
}

resource "kubernetes_manifest" "smtp" {
  manifest = yamldecode(local.vpa_smtp)

  depends_on = [
    kubernetes_namespace.environment_namespace
  ]
}
