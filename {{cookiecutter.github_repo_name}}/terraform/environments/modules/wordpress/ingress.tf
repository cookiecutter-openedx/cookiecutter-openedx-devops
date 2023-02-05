data "template_file" "ingress" {
  template = file("${path.module}/yml/ingress-wordpress.yaml.tpl")
  vars = {
    environment_namespace = var.environment_namespace
    environment_domain    = var.environment_domain
    wordpress_domain      = var.wordpress_domain
  }
}

resource "kubectl_manifest" "ingress_wordpress" {
  yaml_body = data.template_file.ingress.rendered

  depends_on = [
    helm_release.prometheus
  ]
}
