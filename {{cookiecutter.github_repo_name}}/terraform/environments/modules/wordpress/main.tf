#-----------------------------------------------------------
# NOTE: you must initialize a local helm repo in order to run
# this script.
#
#   brew install helm
#
#   helm repo add bitnami https://charts.bitnami.com/bitnami
#   helm install wordpress bitnami/wordpress
#   helm repo update
#   helm show all bitnami/wordpress
#-----------------------------------------------------------
resource "random_password" "wordpress_password" {
  length           = 16
  special          = true
  override_special = "_%@"
  keepers = {
    version = "1"
  }
}

resource "random_password" "wordpress_admin" {
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
    wordpress-password  = random_password.wordpress_password.result
  }

}

data "template_file" "wordpress-values" {
  template = file("${path.module}/yml/wordpress-values.yaml.tpl")
  vars = {
    existingSecret                    = "wordpress"
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
    PersistenceSelector               = {}
    serviceAccountCreate              = true
    serviceAccountName                = "wordpress"
    serviceAccountAnnotations         = {}
    PodDisruptionBudgetCreate         = true
    HorizontalAutoscalingCreate       = true
    HorizontalAutoscalingMinReplicas  = 1
    HorizontalAutoscalingMaxReplicas  = 2
    externalDatabaseHost              = "localhost"
    externalDatabasePort              = "3306"
    externalDatabaseUser              = "bn_wordpress"
    externalDatabasePassword          = random_password.mariadb.result
    externalDatabaseDatabase          = "bitnami_wordpress"
    externalCacheHost                 = "localhost"
    externalCachePort                 = "11211"
  }
}

resource "helm_release" "wordpress" {
  name             = "wordpress"
  namespace        = var.environment_namespace
  create_namespace = true

  chart      = "wordpress"
  repository = "bitname"
  #version    = "????"

  # https://github.com/bitnami/charts/blob/main/bitnami/wordpress/values.yaml
  values = [
    data.template_file.wordpress-values.rendered
  ]
}
