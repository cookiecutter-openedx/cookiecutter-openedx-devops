
data "template_file" "vpa-cert-manager-cainjector" {
  template = file("${path.module}/yml/verticalpodautoscalers/vpa-openedx-cert-manager-cainjector.yaml.tpl")
  vars = {
    environment_namespace = var.environment_namespace
  }
}

data "template_file" "vpa-cert-manager-webhook" {
  template = file("${path.module}/yml/verticalpodautoscalers/vpa-openedx-cert-manager-webhook.yaml.tpl")
  vars = {
    environment_namespace = var.environment_namespace
  }
}

data "template_file" "vpa-cert-manager" {
  template = file("${path.module}/yml/verticalpodautoscalers/vpa-openedx-cert-manager.yaml.tpl")
  vars = {
    environment_namespace = var.environment_namespace
  }
}

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

data "template_file" "vpa-nginx" {
  template = file("${path.module}/yml/verticalpodautoscalers/vpa-openedx-nginx.yaml.tpl")
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

resource "kubectl_manifest" "vpa-lms" {
  yaml_body = data.template_file.vpa-lms.rendered
}

resource "kubectl_manifest" "vpa-lms-worker" {
  yaml_body = data.template_file.vpa-lms-worker.rendered
}


resource "kubectl_manifest" "vpa-cms" {
  yaml_body = data.template_file.vpa-cms.rendered
}

resource "kubectl_manifest" "vpa-cms-worker" {
  yaml_body = data.template_file.vpa-cms-worker.rendered
}

resource "kubectl_manifest" "vpa-mfe" {
  yaml_body = data.template_file.vpa-mfe.rendered
}

resource "kubectl_manifest" "vpa-elasticsearch" {
  yaml_body = data.template_file.vpa-elasticsearch.rendered
}

resource "kubectl_manifest" "vpa-discovery" {
  yaml_body = data.template_file.vpa-discovery.rendered
}

resource "kubectl_manifest" "mongodb" {
  yaml_body = data.template_file.vpa-mongodb.rendered
}

resource "kubectl_manifest" "notes" {
  yaml_body = data.template_file.vpa-notes.rendered
}

resource "kubectl_manifest" "smtp" {
  yaml_body = data.template_file.vpa-smtp.rendered
}

resource "kubectl_manifest" "nginx" {
  yaml_body = data.template_file.vpa-nginx.rendered
}

resource "kubectl_manifest" "cert-manager" {
  yaml_body = data.template_file.vpa-cert-manager.rendered
}

resource "kubectl_manifest" "cert-manager-cainjector" {
  yaml_body = data.template_file.vpa-cert-manager-cainjector.rendered
}

resource "kubectl_manifest" "cert-manager-webhook" {
  yaml_body = data.template_file.vpa-cert-manager-webhook.rendered
}
