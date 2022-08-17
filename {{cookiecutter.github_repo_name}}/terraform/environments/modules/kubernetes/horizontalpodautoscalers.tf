data "template_file" "hpa-cms-worker" {
  template = file("${path.module}/yml/horizontalpodautoscalers/hpa-openedx-cms-worker.yaml.tpl")
  vars = {
    environment_namespace = var.environment_namespace
  }
}

data "template_file" "hpa-cms" {
  template = file("${path.module}/yml/horizontalpodautoscalers/hpa-openedx-cms.yaml.tpl")
  vars = {
    environment_namespace = var.environment_namespace
  }
}

data "template_file" "hpa-discovery" {
  template = file("${path.module}/yml/horizontalpodautoscalers/hpa-openedx-discovery.yaml.tpl")
  vars = {
    environment_namespace = var.environment_namespace
  }
}

data "template_file" "hpa-lms-worker" {
  template = file("${path.module}/yml/horizontalpodautoscalers/hpa-openedx-lms-worker.yaml.tpl")
  vars = {
    environment_namespace = var.environment_namespace
  }
}

data "template_file" "hpa-lms" {
  template = file("${path.module}/yml/horizontalpodautoscalers/hpa-openedx-lms.yaml.tpl")
  vars = {
    environment_namespace = var.environment_namespace
  }
}

data "template_file" "hpa-mfe" {
  template = file("${path.module}/yml/horizontalpodautoscalers/hpa-openedx-mfe.yaml.tpl")
  vars = {
    environment_namespace = var.environment_namespace
  }
}

data "template_file" "hpa-notes" {
  template = file("${path.module}/yml/horizontalpodautoscalers/hpa-openedx-notes.yaml.tpl")
  vars = {
    environment_namespace = var.environment_namespace
  }
}

data "template_file" "hpa-smtp" {
  template = file("${path.module}/yml/horizontalpodautoscalers/hpa-openedx-smtp.yaml.tpl")
  vars = {
    environment_namespace = var.environment_namespace
  }
}

resource "kubectl_manifest" "hpa-cms-worker" {
  yaml_body = data.template_file.hpa-cms-worker.rendered
}

resource "kubectl_manifest" "hpa-cms" {
  yaml_body = data.template_file.hpa-cms.rendered
}

resource "kubectl_manifest" "hpa-discovery" {
  yaml_body = data.template_file.hpa-discovery.rendered
}

resource "kubectl_manifest" "hpa-lms-worker" {
  yaml_body = data.template_file.hpa-lms-worker.rendered
}

resource "kubectl_manifest" "hpa-lms" {
  yaml_body = data.template_file.hpa-lms.rendered
}

resource "kubectl_manifest" "hpa-mfe" {
  yaml_body = data.template_file.hpa-mfe.rendered
}

resource "kubectl_manifest" "hpa-notes" {
  yaml_body = data.template_file.hpa-notes.rendered
}

resource "kubectl_manifest" "hpa-smtp" {
  yaml_body = data.template_file.hpa-smtp.rendered
}
