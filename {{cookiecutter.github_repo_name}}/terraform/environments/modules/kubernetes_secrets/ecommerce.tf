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
    namespace = var.namespace
  }

  data = {
    ECOMMERCE_ENABLE_IDENTITY_VERIFICATION           = true
    ECOMMERCE_ENABLED_PAYMENT_PROCESSORS             = "stripe, paypal"
    ECOMMERCE_ENABLED_CLIENT_SIDE_PAYMENT_PROCESSORS = ""
    ECOMMERCE_EXTRA_PAYMENT_PROCESSOR_CLASSES        = ""
    ECOMMERCE_CURRENCY                               = "USD"
    ECOMMERCE_EXTRA_PIP_REQUIREMENTS                 = ""
    ECOMMERCE_PAYMENT_PROCESSORS                     = file("${path.module}/ecommerce-config.yml")
  }
}
