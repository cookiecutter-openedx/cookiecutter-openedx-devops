#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: April 2022
#
# usage: create an RDS MySQL instance.
#------------------------------------------------------------------------------

data "aws_rds_cluster" "clusterName" {
  cluster_identifier = var.db_instance_id
}
