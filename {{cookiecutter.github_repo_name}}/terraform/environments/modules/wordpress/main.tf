#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: install Wordpress its own namespace.
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
#   Trouble shooting an installation:
#   helm ls --namespace my-wordpress-site
#   helm history wordpress  --namespace my-wordpress-site
#   helm rollback wordpress 4 --namespace my-wordpress-site
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
  ebsVolumePreventDestroy          = var.wordpressConfig["DiskVolumePreventDestroy"]
  aws_ebs_volume_id                = var.wordpressConfig["AWSEBSVolumeId"]
  serviceAccountName               = local.wordpressDomain
  HorizontalAutoscalingMinReplicas = 1
  HorizontalAutoscalingMaxReplicas = 1
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
    wordpressExistingSecret          = kubernetes_secret.wordpress_config.metadata[0].name
    wordpressEmail                   = local.wordpressEmail
    wordpressFirstName               = local.wordpressFirstName
    wordpressLastName                = local.wordpressLastName
    wordpressBlogName                = local.wordpressBlogName
    wordpressExtraConfigContent      = data.template_file.wordpressExtraConfigContent.rendered
    wordpressConfigureCache          = false
    wordpressPlugins                 = data.template_file.wordpressPlugins.rendered
    allowEmptyPassword               = false
    extraVolumes                     = data.template_file.extraVolumes.rendered
    extraVolumeMounts                = data.template_file.extraVolumeMounts.rendered
    persistenceSize                  = local.persistenceSize
    pvcEbs_volume_id                 = local.aws_ebs_volume_id != "" ? local.aws_ebs_volume_id : aws_ebs_volume.wordpress.volume_id
    serviceAccountCreate             = true
    serviceAccountName               = local.serviceAccountName
    serviceAccountAnnotations        = data.template_file.serviceAccountAnnotations.rendered
    PodDisruptionBudgetCreate        = false
    HorizontalAutoscalingCreate      = false
    HorizontalAutoscalingMinReplicas = local.HorizontalAutoscalingMinReplicas
    HorizontalAutoscalingMaxReplicas = local.HorizontalAutoscalingMaxReplicas
    externalDatabaseHost             = data.kubernetes_secret.mysql_root.data.MYSQL_HOST
    externalDatabasePort             = data.kubernetes_secret.mysql_root.data.MYSQL_PORT
    externalDatabaseUser             = local.externalDatabaseUser
    externalDatabasePassword         = random_password.externalDatabasePassword.result
    externalDatabaseDatabase         = local.externalDatabaseDatabase
    externalDatabaseExistingSecret   = kubernetes_secret.wordpress_config.metadata[0].name
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
    kubernetes_secret.wordpress_config,
    ssh_sensitive_resource.mysql
  ]
}
