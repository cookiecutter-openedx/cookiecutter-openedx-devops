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

  tags = merge(
    var.tags,
    module.cookiecutter_meta.tags,
    {
      "cookiecutter/module/source"    = "{{ cookiecutter.github_repo_name }}/terraform/environments/modules/wordpress"
      "cookiecutter/resource/source"  = "bitnami/wordpress"
      "cookiecutter/resource/version" = "{{ cookiecutter.wordpress_helm_chart_version }}"
    }
  )
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
    wordpressConfigureCache          = false
    allowEmptyPassword               = false
    pvcEbs_volume_id                 = local.aws_ebs_volume_id != "" ? local.aws_ebs_volume_id : aws_ebs_volume.wordpress.id
    serviceAccountCreate             = true
    serviceAccountName               = local.serviceAccountName
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

resource "null_resource" "wordpress_post_deployment" {

  provisioner "local-exec" {
    command = <<-EOT
      # 1. Switch to namespace for this Wordpress deployment.
      #    Find the name of the Wordpress pod using one of the Helm-generated labels
      # ---------------------------------------
      kubectl config set-context --current --namespace=lawrencemcdaniel-api
      POD=$(kubectl get pod -l app.kubernetes.io/name=wordpress -o jsonpath="{.items[0].metadata.name}")

      # 2. shell into the wordpress container of the deployed pod
      #    and execute the post deployment ops
      # ---------------------------------------
      echo "running post deployments scripts on $POD"
      kubectl exec -it $POD --container=wordpress -- /bin/bash -c "touch /opt/bitnami/wordpress/wordfence-waf.php"
    EOT
  }

  depends_on = [
    helm_release.wordpress
  ]
}

#------------------------------------------------------------------------------
#                               COOKIECUTTER META
#------------------------------------------------------------------------------
module "cookiecutter_meta" {
  source = "../../../../../../../common/cookiecutter_meta"
}

resource "kubernetes_secret" "cookiecutter" {
  metadata {
    name      = "cookiecutter"
    namespace = var.cert_manager_namespace
  }

  # https://stackoverflow.com/questions/64134699/terraform-map-to-string-value
  data = {
    tags = jsonencode(local.tags)
  }
}
