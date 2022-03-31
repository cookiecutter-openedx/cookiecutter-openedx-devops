#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create user credentials for oAuth provider in Open edX
#        association occurs during Github Actions deployment workflow.
#------------------------------------------------------------------------------
resource "random_password" "clientid_edx" {
  length  = 40
  special = false
  keepers = {
    version = "1"
  }
}

resource "random_password" "clientsecret_edx" {
  length  = 128
  special = false
  keepers = {
    version = "1"
  }
}


resource "kubernetes_secret" "openedx" {
  metadata {
    name      = "edx-api"
    namespace = var.namespace
  }

  data = {
    CLIENT_ID     = random_password.clientid_edx.result
    CLIENT_SECRET = random_password.clientsecret_edx.result
  }
}
