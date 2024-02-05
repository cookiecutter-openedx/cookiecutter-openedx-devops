#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2022
#
# usage: create an EC2 instance with ssh access and a DNS record.
#------------------------------------------------------------------------------
locals {
  hostname = "bastion.${var.services_subdomain}"

  # Parameterize the bootstrapping script
  templatefile_bastion_config = templatefile("${path.module}/scripts/install.sh.tpl", {
    aws_region = var.aws_region
    namespace  = var.stack_namespace
  })

  templatefile_update = templatefile("${path.module}/scripts/update.sh.tpl", {
    aws_region = var.aws_region
    namespace  = var.stack_namespace
  })

  templatefile_aws_config = templatefile("${path.module}/aws/config.tpl", {
    aws_region = var.aws_region
  })

  templatefile_aws_credentials = templatefile("${path.module}/aws/credentials.tpl", {
    aws_access_key_id     = aws_iam_access_key.aws_cli.id
    aws_secret_access_key = aws_iam_access_key.aws_cli.secret
  })

  templatefile_welcome_banner = templatefile("${path.module}/etc/update-motd.d/09-welcome-banner.tpl", {
    platform_name = var.platform_name
  })

  templatefile_help_text = templatefile("${path.module}/etc/update-motd.d/10-help-text.tpl", {
    stack_namespace    = var.stack_namespace
    services_subdomain = var.services_subdomain
    aws_region         = var.aws_region
  })

  tags = merge(
    var.tags,
    module.cookiecutter_meta.tags,
    {
      "cookiecutter/module/source"  = "{{ cookiecutter.github_repo_name }}/terraform/stacks/modules/ec2_bastion"
      "cookiecutter/module/version" = ""
    }
  )

}
resource "aws_instance" "bastion" {

  ami               = data.aws_ami.ubuntu.id
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  key_name          = aws_key_pair.bastion.key_name
  subnet_id         = var.subnet_ids[random_integer.subnet_id.result]
  monitoring        = false
  ebs_optimized     = false

  tags = merge(
    local.tags,
    {
      "cookiecutter/resource/source"  = "hashicorp/aws/aws_instance"
      "cookiecutter/resource/version" = "{{ cookiecutter.terraform_provider_hashicorp_aws_version }}"
    }
  )

  vpc_security_group_ids = [
    resource.aws_security_group.sg_bastion.id,
    data.aws_security_group.stack-namespace-node.id
  ]

  root_block_device {
    delete_on_termination = true
    volume_size           = var.volume_size
    tags = merge(
      local.tags,
      {
        "cookiecutter/resource/source"  = "hashicorp/aws/aws_instance"
        "cookiecutter/resource/version" = "{{ cookiecutter.terraform_provider_hashicorp_aws_version }}"
      }
    )
  }

  # aws cli configuration
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.bastion.private_key_pem
      host        = self.public_ip
    }

    inline = [
      "mkdir ~/.aws",
      "mkdir ~/scripts",
      "rm -rf /tmp/cookiecutter",
      "mkdir /tmp/cookiecutter",
      "mkdir /tmp/cookiecutter/etc/",
      "echo PATH='$HOME/scripts:$PATH' >> ~/.profile",

      # report what we've done so far
      "echo created folder /tmp/cookiecutter",
      "echo created folder ~/.aws",
      "echo created folder ~/scripts",
      "echo added ~/scripts to path",
      "echo added $HOME/scripts to PATH",
    ]
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.bastion.private_key_pem
      host        = self.public_ip
    }

    content     = local.templatefile_aws_config
    destination = "/home/ubuntu/.aws/config"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.bastion.private_key_pem
      host        = self.public_ip
    }

    content     = local.templatefile_aws_credentials
    destination = "/home/ubuntu/.aws/credentials"
  }

  # login banner
  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.bastion.private_key_pem
      host        = self.public_ip
    }

    content     = local.templatefile_welcome_banner
    destination = "/tmp/cookiecutter/etc/09-welcome-banner"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.bastion.private_key_pem
      host        = self.public_ip
    }

    content     = local.templatefile_help_text
    destination = "/tmp/cookiecutter/etc/10-help-text"
  }

  # installation bootstrapper script
  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.bastion.private_key_pem
      host        = self.public_ip
    }

    source      = "${path.module}/scripts/"
    destination = "/home/ubuntu/scripts/"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.bastion.private_key_pem
      host        = self.public_ip
    }

    content     = local.templatefile_bastion_config
    destination = "/home/ubuntu/scripts/install.sh"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.bastion.private_key_pem
      host        = self.public_ip
    }

    content     = local.templatefile_update
    destination = "/home/ubuntu/scripts/update.sh"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.bastion.private_key_pem
      host        = self.public_ip
    }

    inline = [
      # 1.) report what we've done
      "echo installed aws cli configuration",
      "echo installed scripts",

      # 2.) final install tasks for files that we're adding to the ec2 instance
      "chown ubuntu /home/ubuntu/scripts/*.sh",
      "chgrp ubuntu /home/ubuntu/scripts/*.sh",
      "chmod 755 /home/ubuntu/scripts/*.sh",
      "rm /home/ubuntu/scripts/*.sh.tpl",

      # run installation tasks, to add login banner, etc.
      "/home/ubuntu/scripts/install-tasks.sh",
      "rm /home/ubuntu/scripts/install-tasks.sh",

      # FIX ME!
      #  "echo Bootstrapping. This will take around 15 minutes ...",
      #  "/home/ubuntu/scripts/install.sh",

      # 3.) clean up
      "rm -rf /tmp/cookiecutter",
    ]
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


#------------------------------------------------------------------------------
#                        SUPPORTING RESOURCES
#------------------------------------------------------------------------------


# Ubuntu 20.04 LTS AMI
# see: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami_ids
#
# mcdaniel: note that Ubuntu 20.0.04 is the latest version onto which MongoDB 4.2 can install.
#           We install mongo in order to use the mongodb client from bastion.
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

# randomize the choice of subnet. Each of the three
# possible subnets corresponds to the AWS availability
# zones in the data center. Most data center have 3
# availability zones.
resource "random_integer" "subnet_id" {
  min = 0
  max = 2
}

data "aws_security_group" "stack-namespace-node" {
  tags = {
    Name = "${var.stack_namespace}-node"
  }
}


# create a dedicated security group for the bastion that
# only allows public ssh access.
resource "aws_security_group" "sg_bastion" {
  name_prefix = "${var.resource_name}-bastion"
  description = "cookiecutter: Public ssh access"
  vpc_id      = var.vpc_id

  ingress {
    description = "cookiecutter: public ssh from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description      = "cookiecutter: public ssh out to anywhere"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    local.tags,
    {
      "cookiecutter/resource/source"  = "hashicorp/aws/aws_security_group"
      "cookiecutter/resource/version" = "{{ cookiecutter.terraform_provider_hashicorp_aws_version }}"
    }
  )
}


# Create a static IP address and a DNS record to
# add to the root domain.
resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  tags = merge(
    local.tags,
    {
      "cookiecutter/resource/source"  = "hashicorp/aws/aws_eip"
      "cookiecutter/resource/version" = "{{ cookiecutter.terraform_provider_hashicorp_aws_version }}"
    }
  )
}


# private ssh key for public access to the bastion.
# we'll store this in kubernetes secrets so that we have
# a long-term means of retrieving the private key.
resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion" {
  key_name   = "${var.resource_name}-bastion"
  public_key = tls_private_key.bastion.public_key_openssh
}





# Create an IAM user with a key/secret to use with the aws cli.
# Then create handles to template files for the aws cli configuration
# to be saved in ~/.aws/ via a provision in aws_instance.bastion
resource "aws_iam_user" "aws_cli" {
  name = "${var.resource_name}-bastion"
  path = "/system/bastion-user/"
  tags = merge(
    local.tags,
    {
      "cookiecutter/resource/source"  = "hashicorp/aws/aws_iam_user"
      "cookiecutter/resource/version" = "{{ cookiecutter.terraform_provider_hashicorp_aws_version }}"
    }
  )
}

resource "aws_iam_access_key" "aws_cli" {
  user = aws_iam_user.aws_cli.name
}

resource "aws_iam_user_policy_attachment" "AdministratorAccess" {
  user       = aws_iam_user.aws_cli.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "kubernetes_secret" "aws_cli" {
  metadata {
    name      = "bastion-aws-cli-key"
    namespace = var.stack_namespace
  }

  data = {
    KEY    = aws_iam_access_key.aws_cli.id
    SECRET = aws_iam_access_key.aws_cli.secret
  }
}


#------------------------------------------------------------------------------
#                               COOKIECUTTER META
#------------------------------------------------------------------------------
module "cookiecutter_meta" {
  source = "../../../../../../../common/cookiecutter_meta"
}
