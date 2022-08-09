#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create an admin password for an Open edX superuser account.
#        association happens during Github Action deployment workflow.
#------------------------------------------------------------------------------
resource "random_password" "admin_edx" {
  length  = 16
  special = false
  keepers = {
    version = "1"
  }
}

resource "kubernetes_secret" "admin_edx" {
  metadata {
    name      = "admin-edx"
    namespace = var.environment_namespace
  }

  data = {
    ADMIN_USER     = "admin"
    ADMIN_PASSWORD = random_password.admin_edx.result
    ADMIN_EMAIL    = "admin@${var.root_domain}"
  }
}
