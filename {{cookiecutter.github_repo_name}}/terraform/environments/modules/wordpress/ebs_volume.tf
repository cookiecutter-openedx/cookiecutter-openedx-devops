#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: create a detachable EBS volume to be used as the primary storage
#        volume for Wordpress.
#------------------------------------------------------------------------------

# create a detachable EBS volume for the wordpress databases
resource "aws_ebs_volume" "wordpress" {
  availability_zone = data.aws_subnet.private_subnet.availability_zone
  size              = local.persistenceSize
  tags              = var.tags

  # un-comment this block if you want to prevent Terraform from destroying the wordpress volume.
  lifecycle {
    prevent_destroy = true
  }

}

#------------------------------------------------------------------------------
#                        SUPPORTING RESOURCES
#------------------------------------------------------------------------------

data "aws_subnet" "private_subnet" {
  id = var.subnet_ids[random_integer.subnet_id.result]
}

# randomize the choice of subnet. Each of the three
# possible subnets corresponds to the AWS availability
# zones in the data center. Most data center have 3
# availability zones.
resource "random_integer" "subnet_id" {
  min = 0
  max = length(var.subnet_ids) - 1
}
