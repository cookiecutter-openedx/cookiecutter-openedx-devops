#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: April 2022
#
# usage: create an RDS MySQL instance.
#        store the MySQL credentials in Kubernetes Secrets
#------------------------------------------------------------------------------
resource "kubernetes_secret" "ssh_secret" {
  metadata {
    name      = "bastion-ssh-key"
    namespace = var.stack_namespace
  }

  # mcdaniel aug-2022: switch from DNS host name
  # to EC2 public ip address bc of occasional delays
  # in updates to Route53 DNS
  data = {
    HOST            = aws_eip.bastion.public_ip
    USER            = "ubuntu"
    PRIVATE_KEY_PEM = tls_private_key.bastion.private_key_pem
  }
}
