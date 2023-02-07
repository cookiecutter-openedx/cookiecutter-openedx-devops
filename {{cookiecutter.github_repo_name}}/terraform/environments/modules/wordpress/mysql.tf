#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: Feb-2023
#
# usage: Wordpress MySQL resources
#------------------------------------------------------------------------------

data "template_file" "mysql_config" {
  template = file("${path.module}/config/mysql-config.sql.tpl")
  vars = {
    MYSQL_HOST               = data.kubernetes_secret.mysql_root.data.MYSQL_HOST
    MYSQL_PORT               = data.kubernetes_secret.mysql_root.data.MYSQL_PORT
    MYSQL_ROOT_USERNAME      = data.kubernetes_secret.mysql_root.data.MYSQL_ROOT_USERNAME
    MYSQL_ROOT_PASSWORD      = data.kubernetes_secret.mysql_root.data.MYSQL_ROOT_PASSWORD
    WORDPRESS_MYSQL_DATABASE = local.externalDatabaseDatabase
    WORDPRESS_MYSQL_USERNAME = local.externalDatabaseUser
    WORDPRESS_MYSQL_PASSWORD = random_password.externalDatabasePassword.result
  }
}

# login to the bastion EC2 instance and execute mysql-config.sh
resource "ssh_sensitive_resource" "mysql" {
  triggers = {
    always_run = "${timestamp()}"
  }

  host        = data.kubernetes_secret.bastion.data.HOST
  user        = data.kubernetes_secret.bastion.data.USER
  private_key = data.kubernetes_secret.bastion.data.PRIVATE_KEY_PEM
  agent       = false

  file {
    content     = data.template_file.mysql_config.rendered
    destination = "/tmp/mysql-config.sh"
    permissions = "0755"
  }

  timeout     = "1m"
  retry_delay = "10s"

  commands = [
    "/tmp/mysql-config.sh",
    "rm /tmp/mysql-config.sh"
  ]
}
