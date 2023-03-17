#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: aug-2022
#
# usage: create environment connection resources for remote MongoDB instance.
#        store the MongoDB credentials in Kubernetes Secrets
#------------------------------------------------------------------------------
# Retrieve the mongodb_admin connection parameters from the shared resource namespace.
# we'll refer to this data for the HOST and PORT assignments on all other MySQL
# secrets.
data "kubernetes_secret" "mongodb_admin" {
  metadata {
    name      = "mongodb-admin"
    namespace = var.shared_resource_namespace
  }
}

resource "kubernetes_secret" "mongodb_admin" {
  metadata {
    name      = "mongodb-admin"
    namespace = var.environment_namespace
  }

  data = {
    MONGODB_ADMIN_USERNAME = data.kubernetes_secret.mongodb_admin.data.MONGODB_ADMIN_USERNAME
    MONGODB_ADMIN_PASSWORD = data.kubernetes_secret.mongodb_admin.data.MONGODB_ADMIN_PASSWORD
    MONGODB_HOST           = data.kubernetes_secret.mongodb_admin.data.MONGODB_HOST
    MONGODB_PORT           = data.kubernetes_secret.mongodb_admin.data.MONGODB_PORT
  }
}

resource "kubernetes_secret" "openedx" {
  metadata {
    name      = "mongodb-openedx"
    namespace = var.environment_namespace
  }

  data = {
    # see: https://docs.tutor.overhang.io/configuration.html
    # -------------------------------------------------------------------------
    MONGODB_DATABASE = substr("${var.db_prefix}_edx", -32, -1)
    MONGODB_HOST     = data.kubernetes_secret.mongodb_admin.data.MONGODB_HOST
    MONGODB_USERNAME = ""
    MONGODB_PASSWORD = ""
    # you can harden security by adding auth
    # credentials here
    #MONGODB_USERNAME           = substr("${var.db_prefix}_edx", -32, -1)
    #MONGODB_PASSWORD           = random_password.mongodb_openedx.result
    MONGODB_PORT           = data.kubernetes_secret.mongodb_admin.data.MONGODB_PORT
    MONGODB_USE_SSL        = "false"
    MONGODB_REPLICA_SET    = ""
    MONGODB_AUTH_MECHANISM = ""
    MONGODB_AUTH_SOURCE    = "admin"

    # see: https://github.com/overhangio/tutor-forum
    # -------------------------------------------------------------------------
    FORUM_MONGODB_DATABASE    = substr("${var.db_prefix}_cs_comments", -32, -1)
    FORUM_MONGODB_USE_SSL     = "false"
    FORUM_MONGODB_AUTH_SOURCE = ""
    FORUM_MONGODB_AUTH_MECH   = ""
  }
}
