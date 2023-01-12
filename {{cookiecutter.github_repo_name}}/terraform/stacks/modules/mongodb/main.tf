#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Aug-2022
#
# usage: create a remote MongoDB server with access limited to the VPC.
#        - EC2 instance with ssh access from the bastion and a DNS record
#        - preconfigure bastion with private key and ssh config to this instance
#        - add aws cli configuration with dedicated IAM user limited to S3 bucket access
#        - attach to dedicated EBS volume for MongoDB data
#        - configure mongod to allow remote connections.
#        - add a login welcome banner w getting started help
#        - automate the software installation
#        - create dedicated security group to limit ingress to the VPC on port 27017
#        - add k8s nodes security groups to this instance
#        - add connection data to k8s secrets
#        - create an admin user and password, and add to k8s secrets
#
# see:
#   https://www.digitalocean.com/community/tutorials/how-to-configure-remote-access-for-mongodb-on-ubuntu-20-04
#------------------------------------------------------------------------------
locals {
  ssh_private_key_filename = "${var.stack_namespace}-mongodb.pem"
  host_name                = "mongodb.${var.services_subdomain}"
}

# create the MongoDB instance and install configuration files.
resource "aws_instance" "mongodb" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.mongodb.key_name
  subnet_id                   = var.subnet_id
  monitoring                  = false
  associate_public_ip_address = false
  ebs_optimized               = false
  tags                        = var.tags

  vpc_security_group_ids = [
    aws_security_group.sg_mongodb.id,
    data.aws_security_group.stack-namespace-node.id,
    data.aws_security_group.k8s_nodes.id
  ]

  root_block_device {
    delete_on_termination = true
    volume_size           = 8
    tags                  = var.tags
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = data.kubernetes_secret.bastion_ssh_key.data["USER"]
      private_key = data.kubernetes_secret.bastion_ssh_key.data["PRIVATE_KEY_PEM"]
      host        = data.kubernetes_secret.bastion_ssh_key.data["HOST"]
    }

    content     = data.template_file.preinstall_tasks.rendered
    destination = "/home/ubuntu/scripts/mongodb-preinstall-tasks.sh"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = data.kubernetes_secret.bastion_ssh_key.data["USER"]
      private_key = data.kubernetes_secret.bastion_ssh_key.data["PRIVATE_KEY_PEM"]
      host        = data.kubernetes_secret.bastion_ssh_key.data["HOST"]
    }

    inline = [
      "echo Connected to the bastion",
      "chmod 755 /home/ubuntu/scripts/*.sh",
      "/home/ubuntu/scripts/mongodb-preinstall-tasks.sh",
    ]
  }

  # login banner
  provisioner "file" {
    connection {
      type        = "ssh"
      user        = data.kubernetes_secret.bastion_ssh_key.data["USER"]
      private_key = data.kubernetes_secret.bastion_ssh_key.data["PRIVATE_KEY_PEM"]
      host        = data.kubernetes_secret.bastion_ssh_key.data["HOST"]
    }

    content     = data.template_file.welcome_banner.rendered
    destination = "/tmp/openedx_devops/mongodb/etc/09-welcome-banner"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = data.kubernetes_secret.bastion_ssh_key.data["USER"]
      private_key = data.kubernetes_secret.bastion_ssh_key.data["PRIVATE_KEY_PEM"]
      host        = data.kubernetes_secret.bastion_ssh_key.data["HOST"]
    }

    source      = "${path.module}/etc/update-motd.d/10-help-text"
    destination = "/tmp/openedx_devops/mongodb/etc/10-help-text"
  }


  provisioner "file" {
    connection {
      type        = "ssh"
      user        = data.kubernetes_secret.bastion_ssh_key.data["USER"]
      private_key = data.kubernetes_secret.bastion_ssh_key.data["PRIVATE_KEY_PEM"]
      host        = data.kubernetes_secret.bastion_ssh_key.data["HOST"]
    }

    content     = data.template_file.aws_config.rendered
    destination = "/tmp/openedx_devops/mongodb/.aws/config"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = data.kubernetes_secret.bastion_ssh_key.data["USER"]
      private_key = data.kubernetes_secret.bastion_ssh_key.data["PRIVATE_KEY_PEM"]
      host        = data.kubernetes_secret.bastion_ssh_key.data["HOST"]
    }

    content     = data.template_file.aws_credentials.rendered
    destination = "/tmp/openedx_devops/mongodb/.aws/credentials"
  }

  # installation bootstrapper script
  provisioner "file" {
    connection {
      type        = "ssh"
      user        = data.kubernetes_secret.bastion_ssh_key.data["USER"]
      private_key = data.kubernetes_secret.bastion_ssh_key.data["PRIVATE_KEY_PEM"]
      host        = data.kubernetes_secret.bastion_ssh_key.data["HOST"]
    }

    source      = "${path.module}/scripts/"
    destination = "/tmp/openedx_devops/mongodb/scripts/"
  }

  # add ssh key to the bastion
  provisioner "file" {
    connection {
      type        = "ssh"
      user        = data.kubernetes_secret.bastion_ssh_key.data["USER"]
      private_key = data.kubernetes_secret.bastion_ssh_key.data["PRIVATE_KEY_PEM"]
      host        = data.kubernetes_secret.bastion_ssh_key.data["HOST"]
    }

    content     = tls_private_key.mongodb.private_key_pem
    destination = "/home/ubuntu/.ssh/${local.ssh_private_key_filename}"
  }


  # we mostly only want to create and destroy. No updates, as these nearly always
  # result in the instance being recreated which, in turn results in the root
  # volume getting destroyed. Yikes!!!!
  lifecycle {
    ignore_changes = [
      security_groups,
      ami,
      tags
    ]
  }
}

# MongoDB installation script. This runs from bastion and needs
# the dynamically-assigned internal ip address of the MongoDB
# instance. we therefore hive this off into it's own
# resource, that depends on aws_instance.mongodb in order
# to be able to programatically retrieve the internal ip address.
resource "null_resource" "install_script" {

  triggers = {
    mongodb_instance = aws_instance.mongodb.id
    install_script   = data.template_file.install_tasks.rendered
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = data.kubernetes_secret.bastion_ssh_key.data["USER"]
      private_key = data.kubernetes_secret.bastion_ssh_key.data["PRIVATE_KEY_PEM"]
      host        = data.kubernetes_secret.bastion_ssh_key.data["HOST"]
    }

    content     = data.template_file.mongod_conf.rendered
    destination = "/tmp/openedx_devops/mongodb/etc/mongod.conf"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = data.kubernetes_secret.bastion_ssh_key.data["USER"]
      private_key = data.kubernetes_secret.bastion_ssh_key.data["PRIVATE_KEY_PEM"]
      host        = data.kubernetes_secret.bastion_ssh_key.data["HOST"]
    }

    content     = data.template_file.install_tasks.rendered
    destination = "/home/ubuntu/scripts/mongodb-install-tasks.sh"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = data.kubernetes_secret.bastion_ssh_key.data["USER"]
      private_key = data.kubernetes_secret.bastion_ssh_key.data["PRIVATE_KEY_PEM"]
      host        = data.kubernetes_secret.bastion_ssh_key.data["HOST"]
    }


    inline = [
      "echo finished copying files from Terraform to the bastion",
      "chmod 755 /home/ubuntu/scripts/*.sh",
      "/home/ubuntu/scripts/mongodb-install-tasks.sh"
    ]
  }

  depends_on = [
    aws_instance.mongodb
  ]
}

#------------------------------------------------------------------------------
#                        SUPPORTING RESOURCES
#------------------------------------------------------------------------------

data "aws_ebs_volume" "mongodb" {
  most_recent = true

  filter {
    name   = "availability-zone"
    values = ["${var.availability_zone}"]
  }

  filter {
    name   = "tag:Name"
    values = ["${var.resource_name}"]
  }

  filter {
    name   = "size"
    values = ["${var.allocated_storage}"]
  }
}

resource "aws_volume_attachment" "mongodb" {
  device_name = "/dev/sdh"
  volume_id   = data.aws_ebs_volume.mongodb.id
  instance_id = aws_instance.mongodb.id
}


# Ubuntu 20.04 LTS AMI
# see: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami_ids
#
# mcdaniel: note that Ubuntu 20.0.04 is the latest version onto which MongoDB 4.2 can install
data "aws_ami" "ubuntu" {

  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

data "kubernetes_secret" "bastion_ssh_key" {
  metadata {
    name      = "bastion-ssh-key"
    namespace = var.stack_namespace
  }
}

data "aws_security_group" "k8s_nodes" {
  tags = {
    Name = "${var.stack_namespace}-node"
  }
}


data "aws_security_group" "stack-namespace-node" {
  tags = {
    Name = "${var.stack_namespace}-node"
  }
}

# create a dedicated security group for the mongodb server that
# only allows inbound traffice to port 27017.
resource "aws_security_group" "sg_mongodb" {
  name_prefix = "${var.stack_namespace}-mongodb"
  description = "openedx_devops: MongoDB access from within VPC"
  vpc_id      = var.vpc_id

  ingress {
    description = "openedx_devops: MongoDB access from within VPC"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidr_blocks
  }

  ingress {
    description = "openedx_devops: ssh access to MongoDB from within VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidr_blocks
  }

  egress {
    description      = "openedx_devops: public MongoDB out to anywhere"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags
}


# private ssh key for public access to the mongodb server.
# we'll store this in kubernetes secrets so that we have
# a long-term means of retrieving the private key.
resource "tls_private_key" "mongodb" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "mongodb" {
  key_name   = "${var.stack_namespace}-mongodb"
  public_key = tls_private_key.mongodb.public_key_openssh
}



resource "random_password" "mongodb_admin" {
  length           = 16
  special          = true
  override_special = "_%@"
  keepers = {
    version = "1"
  }
}


# Create an IAM user with a key/secret to use with the aws cli.
# Then create handles to template files for the aws cli configuration
# to be saved in ~/.aws/ via a provision in aws_instance.mongodb
resource "aws_iam_user" "aws_cli" {
  name = "${var.stack_namespace}-mongodb"
  path = "/system/mongodb-user/"
  tags = var.tags
}

resource "aws_iam_access_key" "aws_cli" {
  user = aws_iam_user.aws_cli.name
}

resource "aws_iam_user_policy_attachment" "AmazonS3FullAccess" {
  user       = aws_iam_user.aws_cli.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "kubernetes_secret" "aws_cli" {
  metadata {
    name      = "mongodb-aws-cli-key"
    namespace = var.stack_namespace
  }

  data = {
    KEY    = aws_iam_access_key.aws_cli.id
    SECRET = aws_iam_access_key.aws_cli.secret
  }
}

data "template_file" "aws_config" {
  template = file("${path.module}/aws/config.tpl")
  vars = {
    aws_region = var.aws_region
  }
}

data "template_file" "aws_credentials" {
  template = file("${path.module}/aws/credentials.tpl")
  vars = {
    aws_secret_access_key = aws_iam_access_key.aws_cli.secret
    aws_access_key_id     = aws_iam_access_key.aws_cli.id
  }
}

# mcdaniel aug-2022
# switching to private ip address bc of occasional delays
# in updating Route53 DNS entries.
data "template_file" "ssh_config" {
  template = file("${path.module}/ssh/config.tpl")
  vars = {
    host                 = aws_instance.mongodb.private_ip
    user                 = "ubuntu"
    private_key_filename = local.ssh_private_key_filename
  }
}

data "template_file" "preinstall_tasks" {
  template = file("${path.module}/scripts/mongodb-preinstall-tasks.sh.tpl")
  vars = {
    ssh_private_key_filename = local.ssh_private_key_filename
  }
}

data "template_file" "install_tasks" {
  template = file("${path.module}/scripts/mongodb-install-tasks.sh.tpl")
  vars = {
    ssh_private_key_filename = local.ssh_private_key_filename
    private_ip               = aws_instance.mongodb.private_ip
    ssh_config               = data.template_file.ssh_config.rendered
  }
}

data "template_file" "mongod_conf" {
  template = file("${path.module}/etc/mongod.conf.tpl")
  vars = {
    private_ip = aws_instance.mongodb.private_ip
  }
}

data "template_file" "welcome_banner" {
  template = file("${path.module}/etc/update-motd.d/09-welcome-banner.tpl")
  vars = {
    platform_name = var.platform_name
  }
}
