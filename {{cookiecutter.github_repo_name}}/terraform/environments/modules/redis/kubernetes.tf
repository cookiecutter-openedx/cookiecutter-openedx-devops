#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create an ElastiCache Redis cache
#        stored cache credentials in Kubernetes Secrets.
#------------------------------------------------------------------------------
resource "kubernetes_secret" "environment_redis" {
  metadata {
    name      = "redis"
    namespace = var.environment_namespace
  }

  data = {
    REDIS_KEY_PREFIX = "${var.environment_subdomain}"
    REDIS_HOST       = "redis.primary.${var.environment_domain}"
  }
}
