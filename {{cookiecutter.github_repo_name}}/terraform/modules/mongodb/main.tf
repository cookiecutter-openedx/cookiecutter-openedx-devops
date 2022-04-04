#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2022
#
# usage: setup a DocumentDB MongoDB cluster with connectivity
#        to anything inside the VPN. create DNS records for master and reader.
#------------------------------------------------------------------------------
resource "aws_security_group" "mongo_cluster" {
  name        = var.resource_name
  description = "openedx_devops: DocumentDB cluster"
  vpc_id      = var.vpc_id
  tags        = var.tags
}

# FIX NOTE: VERIFY WHETHER WE ACTUALLY NEED AN EGRESS ON MONGO
#resource "aws_security_group_rule" "egress" {
#  type              = "egress"
#  description       = "Allow all egress traffic"
#  from_port         = 0
#  to_port           = 0
#  protocol          = "-1"
#  cidr_blocks       = ["0.0.0.0/0"]
#  security_group_id = aws_security_group.mongo_cluster.id
#}

resource "aws_security_group_rule" "ingress_security_groups" {
  type              = "ingress"
  description       = "openedx_devops: mongodb llow inbound traffic from the VPC"
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.mongo_cluster.id
}


resource "aws_docdb_cluster" "default" {
  cluster_identifier              = var.resource_name
  master_username                 = var.master_username
  master_password                 = random_password.mongodb_admin.result
  backup_retention_period         = var.retention_period
  preferred_backup_window         = var.preferred_backup_window
  preferred_maintenance_window    = var.preferred_maintenance_window
  final_snapshot_identifier       = lower(var.resource_name)
  skip_final_snapshot             = var.skip_final_snapshot
  deletion_protection             = var.deletion_protection
  apply_immediately               = var.apply_immediately
  storage_encrypted               = var.storage_encrypted
  port                            = var.db_port
  vpc_security_group_ids          = [aws_security_group.mongo_cluster.id]
  db_subnet_group_name            = aws_docdb_subnet_group.default.name
  db_cluster_parameter_group_name = "mongo-cluster-param-group"
  engine                          = var.engine
  engine_version                  = var.engine_version
  tags                            = var.tags
}

resource "aws_docdb_cluster_instance" "default" {
  count                      = var.cluster_size
  identifier                 = "${var.resource_name}-${count.index + 1}"
  cluster_identifier         = join("", aws_docdb_cluster.default.*.id)
  apply_immediately          = var.apply_immediately
  instance_class             = var.instance_class
  engine                     = var.engine
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  tags                       = var.tags
}

resource "aws_docdb_subnet_group" "default" {
  name        = "mongodb_subnet_group"
  description = "openedx_devops: mongodb allowed subnets for DB cluster instances"
  subnet_ids  = var.subnet_ids
  tags        = var.tags
}




# FIX NOTE: WE WANT A LIST OF PARMS, NOT JUST ONE.

resource "aws_docdb_cluster_parameter_group" "no_tls" {
  family      = "docdb3.6"
  name        = "mongo-cluster-param-group"
  description = "openedx_devops: mongodb - disable tls"

  parameter {
    apply_method = "pending-reboot"
    name         = "tls"
    value        = "disabled"
  }

}
