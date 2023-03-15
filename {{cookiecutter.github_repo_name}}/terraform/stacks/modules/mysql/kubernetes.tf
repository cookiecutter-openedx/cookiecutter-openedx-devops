#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: April 2022
#
# usage: create an RDS MySQL instance.
#        store the MySQL credentials in Kubernetes Secrets
#------------------------------------------------------------------------------

resource "kubernetes_secret" "mysql_root" {
  metadata {
    name      = "mysql-root"
    namespace = var.resource_name
  }

  data = {
    MYSQL_ROOT_USERNAME = module.db.db_instance_username
    MYSQL_ROOT_PASSWORD = module.db.db_instance_password
    MYSQL_HOST          = local.host_name
    MYSQL_PORT          = module.db.db_instance_port
  }
}
