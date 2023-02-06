#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: Feb-2023
#
# usage: Wordpress MySQL resources
#------------------------------------------------------------------------------

provider "mysql" {
  endpoint = data.kubernetes_secret.mysql_root.data.MYSQL_HOST
  username = data.kubernetes_secret.mysql_root.data.MYSQL_ROOT_USERNAME
  password = data.kubernetes_secret.mysql_root.data.MYSQL_ROOT_PASSWORD
  port     = data.kubernetes_secret.mysql_root.data.MYSQL_PORT
}

# Create a second database, in addition to the "initial_db" created
# by the aws_db_instance resource above.
resource "mysql_database" "wordpress" {
  name = var.wordpressConfig["Database"]
}

resource "mysql_user" "wordpress_admin" {
  user               = var.wordpressConfig["Username"]
  host               = "%"
  plaintext_password = random_password.externalDatabasePassword.result
}

resource "mysql_grant" "wordpress_admin" {
  user       = mysql_user.wordpress_admin.user
  host       = mysql_user.wordpress_admin.host
  database   = mysql_database.wordpress.name
  privileges = ["ALL"]
}
