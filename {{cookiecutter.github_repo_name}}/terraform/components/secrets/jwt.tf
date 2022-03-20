#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create a JWT for Open edX configuration.
#        association happens during Github Action deployment workflow.
#------------------------------------------------------------------------------
resource "tls_private_key" "jwt_rsa_private_key" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "kubernetes_secret" "jtw" {
  metadata {
    name      = "jwt"
    namespace = var.environment_namespace
  }

  data = {
    private_key = tls_private_key.jwt_rsa_private_key.private_key_pem
  }
}
