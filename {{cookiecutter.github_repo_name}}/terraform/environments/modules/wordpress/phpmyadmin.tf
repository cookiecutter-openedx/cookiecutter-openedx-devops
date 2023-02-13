#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: install phpMyAdmin alongside Wordpress.
#
# NOTE: you must initialize a local helm repo in order to run
# this script.
#
#   brew install helm
#
#   helm repo add bitnami https://charts.bitnami.com/bitnami
#   helm install wordpress bitnami/phpmyadmin
#   helm repo update
#   helm search repo bitnami/phpmyadmin
#   helm show all bitnami/phpmyadmin
#   helm show values bitnami/phpmyadmin
#
# see: https://jmrobles.medium.com/launch-a-wordpress-site-on-kubernetes-in-just-1-minute-193914cb4902
#-----------------------------------------------------------

data "template_file" "phpmyadmin-values" {
  template = file("${path.module}/config/phpmyadmin-values.yaml.tpl")
  vars = {
    externalDatabaseHost             = data.kubernetes_secret.mysql_root.data.MYSQL_HOST
    externalDatabasePort             = data.kubernetes_secret.mysql_root.data.MYSQL_PORT
    externalDatabaseUser             = local.externalDatabaseUser
    externalDatabasePassword         = random_password.externalDatabasePassword.result
    externalDatabaseDatabase         = local.externalDatabaseDatabase
    externalDatabaseExistingSecret   = kubernetes_secret.wordpress_config.metadata[0].name
  }
}

resource "helm_release" "phpmyadmin" {
  name             = "phpmyadmin"
  namespace        = local.wordpressNamespace
  create_namespace = false
  count = "${var.phpmyadmin == "Y" ? 1 : 0}"

  chart      = "phpmyadmin"
  repository = "bitnami"
  version    = "{{ cookiecutter.phpmyadmin_helm_chart_version }}"

  # https://github.com/bitnami/charts/blob/main/bitnami/wordpress/values.yaml
  # or
  # helm show values bitnami/wordpress
  values = [
    data.template_file.phpmyadmin-values.rendered
  ]

  depends_on = [
    kubernetes_namespace.wordpress,
    kubernetes_secret.wordpress_config,
    ssh_sensitive_resource.mysql,
    helm_release.wordpress,
    aws_route53_record.wordpress,
    kubectl_manifest.wordpress_ingress,
    kubectl_manifest.cluster-issuer
  ]
}
