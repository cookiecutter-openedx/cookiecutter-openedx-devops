#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create an ElastiCache Redis cache
#        stored cache credentials in Kubernetes Secrets.
#------------------------------------------------------------------------------
resource "kubernetes_secret" "redis" {
  metadata {
    name      = "redis"
    namespace = var.shared_resource_namespace
  }

  data = {
    REDIS_HOST = module.redis.primary_endpoint_address
  }
}
