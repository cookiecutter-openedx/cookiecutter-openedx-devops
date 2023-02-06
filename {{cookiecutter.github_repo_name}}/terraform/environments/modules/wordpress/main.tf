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
resource "random_password" "wordpress_admin_password" {
  length           = 16
  special          = true
  override_special = "_%@"
  keepers = {
    version = "1"
  }
}

resource "random_password" "mariadb" {
  length           = 16
  special          = true
  override_special = "_%@"
  keepers = {
    version = "1"
  }
}

resource "kubernetes_secret" "wordpress" {
  metadata {
    name      = "wordpress"
    namespace = var.environment_namespace
  }
  data = {
    wordpress-password  = random_password.wordpress_admin_password.result
  }
}

data "template_file" "PersistenceSelector" {
  template = file("${path.module}/yml/persistence-selector.yaml")
}

data "template_file" "serviceAccountAnnotations" {
  template = file("${path.module}/yml/service-account-annotations.yaml")
}

data "template_file" "wordpress-values" {
  template = file("${path.module}/yml/wordpress-values.yaml.tpl")
  vars = {
    existingSecret                    = kubernetes_secret.wordpress
    wordpressUsername                 = "lpm0073"
    wordpressEmail                    = "lpm0073@gmail.com"
    wordpressFirstName                = "Lawrence"
    wordpressLastName                 = "McDaniel"
    wordpressBlogName                 = "Cookiecutter Wordpress Site"
    wordpressExtraConfigContent       = ""
    wordpressConfigureCache           = false
    wordpressPlugins                  = []
    apacheConfiguration               = ""
    smtpHost                          = ""
    smtpPort                          = ""
    smtpUser                          = ""
    smtpProtocol                      = ""
    allowEmptyPassword                = false
    extraVolumes                      = []
    extraVolumeMounts                 = []
    podLabels                         = {}
    podAnnotations                    = {}
    nodeSelector                      = {}
    PersistenceExistingClaim          = ""
    PersistenceSelector               = data.template_file.PersistenceSelector.rendered
    serviceAccountCreate              = true
    serviceAccountName                = "wordpress"
    serviceAccountAnnotations         = data.template_file.serviceAccountAnnotations.rendered
    PodDisruptionBudgetCreate         = true
    HorizontalAutoscalingCreate       = true
    HorizontalAutoscalingMinReplicas  = 1
    HorizontalAutoscalingMaxReplicas  = 2
    externalDatabaseHost              = "localhost"
    externalDatabasePort              = "3306"
    externalDatabaseUser              = "bn_wordpress"
    externalDatabasePassword          = random_password.mariadb.result
    externalDatabaseDatabase          = "bitnami_wordpress"
    memcachedEnabled                  = false
    externalCacheHost                 = "localhost"
    externalCachePort                 = "11211"
  }
}

resource "helm_release" "wordpress" {
  name             = "wordpress"
  namespace        = var.wordpress_namespace
  create_namespace = true

  chart      = "wordpress"
  repository = "bitnami"
  version    = "{{ cookiecutter.terraform_helm_wordpress }}"

  # https://github.com/bitnami/charts/blob/main/bitnami/wordpress/values.yaml
  # or
  # helm show values bitnami/wordpress
  values = [
    data.template_file.wordpress-values.rendered
  ]
}
