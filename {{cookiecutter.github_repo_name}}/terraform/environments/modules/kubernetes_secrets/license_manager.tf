#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:       Aug-2022
#
# usage:      oauth keys and secrets for Open edX License Manager application.
#------------------------------------------------------------------------------
resource "random_password" "lm_oauth2_secret" {
  length  = 16
  special = false
  keepers = {
    version = "1"
  }
}

resource "random_password" "lm_oauth2_secret_sso" {
  length  = 16
  special = false
  keepers = {
    version = "1"
  }
}

resource "random_password" "lm_oauth2_secret_dev" {
  length  = 16
  special = false
  keepers = {
    version = "1"
  }
}

resource "random_password" "lm_oauth2_secret_sso_dev" {
  length  = 16
  special = false
  keepers = {
    version = "1"
  }
}

resource "kubernetes_secret" "lm_oauth" {
  metadata {
    name      = "license-manager-oauth"
    namespace = var.environment_namespace
  }

  data = {
    LICENSE_MANAGER_OAUTH2_KEY_DEV        = "license-manager-key-dev"
    LICENSE_MANAGER_OAUTH2_SECRET_DEV     = random_password.lm_oauth2_secret_dev.result
    LICENSE_MANAGER_OAUTH2_KEY            = "license-manager-key"
    LICENSE_MANAGER_OAUTH2_SECRET         = random_password.lm_oauth2_secret.result
    LICENSE_MANAGER_OAUTH2_KEY_SSO_DEV    = "license-manager-key-sso-dev"
    LICENSE_MANAGER_OAUTH2_SECRET_SSO_DEV = random_password.lm_oauth2_secret_sso_dev.result
    LICENSE_MANAGER_OAUTH2_KEY_SSO        = "license-manager-key-sso"
    LICENSE_MANAGER_OAUTH2_SECRET_SSO     = random_password.lm_oauth2_secret_sso.result
  }
}
