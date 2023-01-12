#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: April 2022
#
# usage: create an RDS MySQL instance.
#------------------------------------------------------------------------------

resource "aws_db_subnet_group" "mysql_subnet_group" {
  name       = "mysql_subnet_group"
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "{{ cookiecutter.terraform_aws_modules_sg }}"

  name        = "${var.resource_name}-mysql"
  description = "openedx_devops: Allow access to MySQL"
  vpc_id      = var.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "openedx_devops: MySQL access from within VPC"
      cidr_blocks = join(",", var.ingress_cidr_blocks)
    },
  ]

  egress_with_cidr_blocks = [
    {
      description      = "openedx_devops: Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = "0.0.0.0/0"
      ipv6_cidr_blocks = "::/0"
    },
  ]
  tags = var.tags
}


#------------------------------------------------------------------------------
# RDS Module
#
# see: https://stackoverflow.com/questions/53386811/terraform-the-db-instance-and-ec2-security-group-are-in-different-vpcs
#------------------------------------------------------------------------------
module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "{{cookiecutter.terraform_aws_modules_rds}}"

  # required parameters (unless we like the default value)
  # ---------------------------------------------------------------------------
  allocated_storage = var.allocated_storage
  #availability_zone =
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  #ca_cert_identifier =
  #character_set_name =
  #cloudwatch_log_group_kms_key_id =
  #db_name =
  #db_subnet_group_description =
  db_subnet_group_name = aws_db_subnet_group.mysql_subnet_group.name
  #domain =
  #domain_iam_role_name =
  engine         = var.engine
  engine_version = var.engine_version
  family         = var.family
  identifier     = var.resource_name
  instance_class = var.instance_class
  #kms_key_id =
  #license_model =
  maintenance_window   = var.maintenance_window
  major_engine_version = var.major_engine_version
  #monitoring_role_arn =
  #monitoring_role_description =
  #option_group_description =
  #option_group_name =
  #parameter_group_description =
  #parameter_group_name =
  #password =
  #performance_insights_kms_key_id =
  port = var.port
  #replica_mode =
  #replicate_source_db =
  #s3_import =
  #snapshot_identifier  =
  #storage_type =
  #timezone =
  username = var.username

  # optional parameters
  # ---------------------------------------------------------------------------
  max_allocated_storage                 = var.max_allocated_storage
  storage_encrypted                     = var.storage_encrypted
  create_random_password                = var.create_random_password
  multi_az                              = var.multi_az
  subnet_ids                            = var.subnet_ids
  vpc_security_group_ids                = [module.security_group.security_group_id]
  enabled_cloudwatch_logs_exports       = var.enabled_cloudwatch_logs_exports
  skip_final_snapshot                   = var.skip_final_snapshot
  deletion_protection                   = var.deletion_protection
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  create_monitoring_role                = var.create_monitoring_role
  monitoring_interval                   = var.monitoring_interval
  parameters                            = var.parameters
  tags                                  = var.tags
}
