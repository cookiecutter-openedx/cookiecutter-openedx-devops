
data "template_file" "vpa-cms" {
  template = file("${path.module}/yml/verticalpodautoscalers/vpa-openedx-cms.yaml.tpl")
  vars = {
    environment_namespace = var.environment_namespace
  }
}

data "template_file" "vpa-cms-worker" {
  template = file("${path.module}/yml/verticalpodautoscalers/vpa-openedx-cms-worker.yaml.tpl")
  vars = {
    environment_namespace = var.environment_namespace
  }
}

data "template_file" "vpa-discovery" {
  template = file("${path.module}/yml/verticalpodautoscalers/vpa-openedx-discovery.yaml.tpl")
  vars = {
    environment_namespace = var.environment_namespace
  }
}

data "template_file" "vpa-elasticsearch" {
  template = file("${path.module}/yml/verticalpodautoscalers/vpa-openedx-elasticsearch.yaml.tpl")
  vars = {
    environment_namespace = var.environment_namespace
  }
}

data "template_file" "vpa-lms" {
  template = file("${path.module}/yml/verticalpodautoscalers/vpa-openedx-lms.yaml.tpl")
  vars = {
    environment_namespace = var.environment_namespace
  }
}

data "template_file" "vpa-lms-worker" {
  template = file("${path.module}/yml/verticalpodautoscalers/vpa-openedx-lms-worker.yaml.tpl")
  vars = {
    environment_namespace = var.environment_namespace
  }
}

data "template_file" "vpa-mfe" {
  template = file("${path.module}/yml/verticalpodautoscalers/vpa-openedx-mfe.yaml.tpl")
  vars = {
    environment_namespace = var.environment_namespace
  }
}

data "template_file" "vpa-mongodb" {
  template = file("${path.module}/yml/verticalpodautoscalers/vpa-openedx-mongodb.yaml.tpl")
  vars = {
    environment_namespace = var.environment_namespace
  }
}


data "template_file" "vpa-notes" {
  template = file("${path.module}/yml/verticalpodautoscalers/vpa-openedx-notes.yaml.tpl")
  vars = {
    environment_namespace = var.environment_namespace
  }
}

data "template_file" "vpa-smtp" {
  template = file("${path.module}/yml/verticalpodautoscalers/vpa-openedx-smtp.yaml.tpl")
  vars = {
    environment_namespace = var.environment_namespace
  }
}

resource "kubernetes_manifest" "vpa-lms" {
  manifest = yamldecode(data.template_file.vpa-lms.rendered)

  depends_on = [
    kubernetes_namespace.environment_namespace
  ]
}

resource "kubernetes_manifest" "vpa-lms-worker" {
  manifest = yamldecode(data.template_file.vpa-lms-worker.rendered)

  depends_on = [
    kubernetes_namespace.environment_namespace
  ]
}


resource "kubernetes_manifest" "vpa-cms" {
  manifest = yamldecode(data.template_file.vpa-cms.rendered)

  depends_on = [
    kubernetes_namespace.environment_namespace
  ]
}

resource "kubernetes_manifest" "vpa-cms-worker" {
  manifest = yamldecode(data.template_file.vpa-cms-worker.rendered)

  depends_on = [
    kubernetes_namespace.environment_namespace
  ]
}

resource "kubernetes_manifest" "vpa-mfe" {
  manifest = yamldecode(data.template_file.vpa-mfe.rendered)

  depends_on = [
    kubernetes_namespace.environment_namespace
  ]
}

resource "kubernetes_manifest" "vpa-elasticsearch" {
  manifest = yamldecode(data.template_file.vpa-elasticsearch.rendered)

  depends_on = [
    kubernetes_namespace.environment_namespace
  ]
}

resource "kubernetes_manifest" "vpa-discovery" {
  manifest = yamldecode(data.template_file.vpa-discovery.rendered)

  depends_on = [
    kubernetes_namespace.environment_namespace
  ]
}

resource "kubernetes_manifest" "mongodb" {
  manifest = yamldecode(data.template_file.vpa-mongodb.rendered)

  depends_on = [
    kubernetes_namespace.environment_namespace
  ]
}

resource "kubernetes_manifest" "notes" {
  manifest = yamldecode(data.template_file.vpa-notes.rendered)

  depends_on = [
    kubernetes_namespace.environment_namespace
  ]
}

resource "kubernetes_manifest" "smtp" {
  manifest = yamldecode(data.template_file.vpa-smtp.rendered)

  depends_on = [
    kubernetes_namespace.environment_namespace
  ]
}
