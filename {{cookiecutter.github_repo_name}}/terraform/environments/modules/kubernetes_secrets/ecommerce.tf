#------------------------------------------------------------------------------
# written by = Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date = July-2022
#
# usage = scaffold the yaml-formatted credentials data for ecommerce configuration.
#        assuming that we'll later revisit this data from k9s, to add keys and secrets.
#------------------------------------------------------------------------------

resource "kubernetes_secret" "ecommerce_config" {
  metadata {
    name      = "ecommerce-config"
    namespace = var.environment_namespace
  }

  data = {
    ECOMMERCE_ENABLE_IDENTITY_VERIFICATION = false
  }
}
