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
#
# see: https://jmrobles.medium.com/launch-a-wordpress-site-on-kubernetes-in-just-1-minute-193914cb4902
#-----------------------------------------------------------
locals {
  wordpress                        = "wordpress"
  wordpressHostedZoneID            = var.wordpressConfig["HostedZoneID"]
  wordpressRootDomain              = var.wordpressConfig["RootDomain"]
  wordpressSubdomain               = var.wordpressConfig["Subdomain"]
  wordpressDomain                  = var.wordpressConfig["Domain"]
  wordpressNamespace               = var.wordpressConfig["Namespace"]
  wordpressUsername                = var.wordpressConfig["Username"]
  wordpressEmail                   = var.wordpressConfig["Email"]
  wordpressFirstName               = var.wordpressConfig["FirstName"]
  wordpressLastName                = var.wordpressConfig["LastName"]
  wordpressBlogName                = var.wordpressConfig["BlogName"]
  externalDatabaseUser             = var.wordpressConfig["DatabaseUser"]
  externalDatabaseDatabase         = var.wordpressConfig["Database"]
  persistenceSize                  = var.wordpressConfig["DiskVolumeSize"]
  serviceAccountName               = "local.wordpress"
  HorizontalAutoscalingMinReplicas = 1
  HorizontalAutoscalingMaxReplicas = 2
  externalCachePort                = "11211"
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

data "template_file" "wordpressExtraConfigContent" {
  template = file("${path.module}/config/wordpress-extra-config-content.php")
}

data "template_file" "wordpress-values" {
  template = file("${path.module}/config/wordpress-values.yaml.tpl")
  vars = {
    wordpressDomain                  = local.wordpressDomain
    wordpressUsername                = local.wordpressUsername
    wordpressEmail                   = local.wordpressEmail
    wordpressFirstName               = local.wordpressFirstName
    wordpressLastName                = local.wordpressLastName
    wordpressBlogName                = local.wordpressBlogName
    wordpressExtraConfigContent      = data.template_file.wordpressExtraConfigContent.rendered
    wordpressConfigureCache          = false
    wordpressPlugins                 = data.template_file.wordpressPlugins.rendered
    allowEmptyPassword               = true
    extraVolumes                     = data.template_file.extraVolumes.rendered
    extraVolumeMounts                = data.template_file.extraVolumeMounts.rendered
    persistenceSize                  = local.persistenceSize
    serviceAccountCreate             = true
    serviceAccountName               = local.serviceAccountName
    serviceAccountAnnotations        = data.template_file.serviceAccountAnnotations.rendered
    PodDisruptionBudgetCreate        = true
    HorizontalAutoscalingCreate      = true
    HorizontalAutoscalingMinReplicas = local.HorizontalAutoscalingMinReplicas
    HorizontalAutoscalingMaxReplicas = local.HorizontalAutoscalingMaxReplicas
    externalDatabaseHost             = data.kubernetes_secret.mysql_root.data.MYSQL_HOST
    externalDatabasePort             = data.kubernetes_secret.mysql_root.data.MYSQL_PORT
    externalDatabaseUser             = local.externalDatabaseUser
    externalDatabasePassword         = random_password.externalDatabasePassword.result
    externalDatabaseDatabase         = local.externalDatabaseDatabase
    externalDatabaseExistingSecret   = kubernetes_secret.wordpress_db.metadata[0].name
    memcachedEnabled                 = false
    externalCacheHost                = data.kubernetes_secret.redis.data.REDIS_HOST
    externalCachePort                = local.externalCachePort
  }
}

resource "helm_release" "wordpress" {
  name             = local.wordpress
  namespace        = local.wordpressNamespace
  create_namespace = false

  chart      = "wordpress"
  repository = "bitnami"
  version    = "{{ cookiecutter.wordpress_helm_chart_version }}"

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
