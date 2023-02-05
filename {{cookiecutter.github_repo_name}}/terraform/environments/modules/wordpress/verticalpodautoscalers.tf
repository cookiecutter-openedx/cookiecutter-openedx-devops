
data "template_file" "vpa-wordpress" {
  template = file("${path.module}/yml/vpa-wordpress.yaml.tpl")
  vars = {
    environment_namespace = var.environment_namespace
  }
}
