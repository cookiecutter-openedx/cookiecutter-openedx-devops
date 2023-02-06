#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# NOTE: you must initialize a local helm repo in order to run
# this script.
#
#   brew install helm
#
#   helm repo add bitnami https://charts.bitnami.com/bitnami
#   helm install wordpress bitnami/wordpress
#   helm repo update
#   helm show all bitnami/wordpress
#   helm show values bitnami/wordpress
#-----------------------------------------------------------
locals {
    wordpress                         = "wordpress"
    wordpressUsername                 = var.wordpressConfig["Username"]
    wordpressEmail                    = var.wordpressConfig["Email"]
    wordpressFirstName                = var.wordpressConfig["FirstName"]
    wordpressLastName                 = var.wordpressConfig["LastName"]
    wordpressBlogName                 = var.wordpressConfig["BlogName"]
    serviceAccountName                = local.wordpress
    HorizontalAutoscalingMinReplicas  = 1
    HorizontalAutoscalingMaxReplicas  = 2
    externalDatabaseUser              = var.wordpressConfig["DatabaseUser"]
    externalDatabaseDatabase          = var.wordpressConfig["Database"]
    externalCachePort                 = "11211"
}



data "template_file" "PersistenceSelector" {
  template = file("${path.module}/config/persistence-selector.json")
}

data "template_file" "serviceAccountAnnotations" {
  template = file("${path.module}/config/service-account-annotations.json")
}

data "template_file" "wordpressPlugins" {
  template = file("${path.module}/config/wordpress-plugins.yaml")
}

data "template_file" "extraVolumes" {
  template = file("${path.module}/config/extra-volumes.json")
}

data "template_file" "extraVolumeMounts" {
  template = file("${path.module}/config/extra-volume-mounts.json")
}

data "template_file" "podLabels" {
  template = file("${path.module}/config/pod-labels.json")
}

data "template_file" "podAnnotations" {
  template = file("${path.module}/config/pod-annotations.json")
}

data "template_file" "nodeSelector" {
  template = file("${path.module}/config/node-selector.json")
}

data "template_file" "wordpressExtraConfigContent" {
  template = file("${path.module}/config/wordpress-extra-config-content.php")
}

data "template_file" "wordpress-values" {
  template = file("${path.module}/config/wordpress-values.yaml.tpl")
  vars = {
    wordpressUsername                 = local.wordpressUsername
    wordpressEmail                    = local.wordpressEmail
    wordpressFirstName                = local.wordpressFirstName
    wordpressLastName                 = local.wordpressFirstName
    wordpressBlogName                 = local.wordpressBlogName
    wordpressExtraConfigContent       = data.template_file.wordpressExtraConfigContent.rendered
    wordpressConfigureCache           = false
    wordpressPlugins                  = data.template_file.wordpressPlugins.rendered
    allowEmptyPassword                = true
    extraVolumes                      = data.template_file.extraVolumes.rendered
    extraVolumeMounts                 = data.template_file.extraVolumeMounts.rendered
    podLabels                         = data.template_file.podLabels.rendered
    podAnnotations                    = data.template_file.podAnnotations.rendered
    nodeSelector                      = data.template_file.nodeSelector.rendered
    PersistenceExistingClaim          = ""
    PersistenceSelector               = data.template_file.PersistenceSelector.rendered
    serviceAccountCreate              = true
    serviceAccountName                = local.serviceAccountName
    serviceAccountAnnotations         = data.template_file.serviceAccountAnnotations.rendered
    PodDisruptionBudgetCreate         = true
    HorizontalAutoscalingCreate       = true
    HorizontalAutoscalingMinReplicas  = local.HorizontalAutoscalingMinReplicas
    HorizontalAutoscalingMaxReplicas  = local.HorizontalAutoscalingMaxReplicas
    externalDatabaseHost              = data.kubernetes_secret.mysql_root.data.MYSQL_HOST
    externalDatabasePort              = data.kubernetes_secret.mysql_root.data.MYSQL_PORT
    externalDatabaseUser              = local.externalDatabaseUser
    externalDatabasePassword          = random_password.externalDatabasePassword.result
    externalDatabaseDatabase          = local.externalDatabaseDatabase
    externalDatabaseExistingSecret    = kubernetes_secret.wordpress_db.metadata[0].name
    memcachedEnabled                  = false
    externalCacheHost                 = data.kubernetes_secret.redis.data.REDIS_HOST
    externalCachePort                 = local.externalCachePort
  }
}

resource "helm_release" "wordpress" {
  name             = local.wordpress
  namespace        = var.wordpressConfig["Namespace"]
  create_namespace = false

  chart      = "wordpress"
  repository = "bitnami"
  version    = "{{ cookiecutter.terraform_helm_wordpress_version }}"

  # https://github.com/bitnami/charts/blob/main/bitnami/wordpress/values.yaml
  # or
  # helm show values bitnami/wordpress
  values = [
    data.template_file.wordpress-values.rendered
  ]

  depends_on = [
    kubernetes_namespace.wordpress,
    ssh_sensitive_resource.mysql
  ]
}
