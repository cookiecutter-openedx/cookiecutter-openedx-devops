#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2022
#
# usage: create an EC2 instance with ssh access and a DNS record.
#------------------------------------------------------------------------------

data "aws_route53_zone" "environment" {
  name = var.environment_domain
}

# Ubuntu 20.04 LTS AMI
# see: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami_ids
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

data "aws_key_pair" "common_key" {
  key_name = var.ec2_ssh_key_name
}

resource "aws_security_group" "sg_bastion" {
  name_prefix = "${var.environment_namespace}-bastion"
  description = "openedx_devops: Public ssh access"
  vpc_id      = var.vpc_id

  ingress {
    description = "openedx_devops: public ssh from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description      = "openedx_devops: public ssh out to anywhere"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags
}


module "bastion" {
  source = "terraform-aws-modules/ec2-instance/aws"

  ami               = data.aws_ami.ubuntu.id
  instance_type     = "t2.micro"
  availability_zone = var.availability_zone
  key_name          = data.aws_key_pair.common_key.key_name

  vpc_security_group_ids = [resource.aws_security_group.sg_bastion.id]
  root_block_device      = [{ volume_size = 100 }]
  subnet_id              = var.subnet_id

  tags = var.tags
}

resource "aws_eip" "elasticip" {
  instance = module.bastion.id
  tags     = var.tags
}

resource "aws_route53_record" "bastion" {
  zone_id = data.aws_route53_zone.environment.id
  name    = "bastion.${var.environment_domain}"
  type    = "A"
  ttl     = "600"


  records = [aws_eip.elasticip.public_ip]
}
