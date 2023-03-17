#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: Aug-2022
#
# usage: create a remote MongoDB instance.
#        store the MySQL credentials in Kubernetes Secrets
#------------------------------------------------------------------------------
resource "kubernetes_secret" "mongodb_admin" {
  metadata {
    name      = "mongodb-admin"
    namespace = var.stack_namespace
  }

  data = {
    MONGODB_ADMIN_USERNAME = "${var.username}"
    MONGODB_ADMIN_PASSWORD = random_password.mongodb_admin.result
    MONGODB_HOST           = aws_route53_record.mongodb.name
    MONGODB_PORT           = "${var.port}"
  }

  depends_on = [
    random_password.mongodb_admin,
    aws_route53_record.mongodb
  ]
}

resource "kubernetes_secret" "ssh_secret" {
  metadata {
    name      = "mongodb-ssh-key"
    namespace = var.stack_namespace
  }

  data = {
    HOST            = aws_route53_record.mongodb.name
    USER            = "ubuntu"
    PRIVATE_KEY_PEM = tls_private_key.mongodb.private_key_pem
  }
}
