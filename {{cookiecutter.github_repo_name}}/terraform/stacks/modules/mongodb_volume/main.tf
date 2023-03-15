#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Aug-2022
#
# usage: create a detachable EBS volume to be used as the primary storage
#        volume for MongoDB.
#------------------------------------------------------------------------------
locals {

  tags = merge(
    var.tags,
    module.cookiecutter_meta.tags,
    {
      "cookiecutter/module/source"  = "{{ cookiecutter.github_repo_name }}/terraform/stacks/mongodb_volume"
    }
  )

}

# create a detachable EBS volume for the Mongodb databases
resource "aws_ebs_volume" "mongodb" {
  availability_zone = data.aws_subnet.database_subnet.availability_zone
  size              = var.allocated_storage

  tags = merge(
    local.tags,
    {
      "cookiecutter/resource/source"  = "hashicorp/aws/aws_ebs_volume"
      "cookiecutter/resource/version" = "{{ cookiecutter.terraform_provider_hashicorp_aws_version }}"
    }
  )

  # un-comment this block if you want to prevent Terraform from destroying the Mongodb volume.
  lifecycle {
    prevent_destroy = true
  }

}

#------------------------------------------------------------------------------
#                        SUPPORTING RESOURCES
#------------------------------------------------------------------------------

data "aws_subnet" "database_subnet" {
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

#------------------------------------------------------------------------------
#                               COOKIECUTTER META
#------------------------------------------------------------------------------
module "cookiecutter_meta" {
  source = "../../../../../../../common/cookiecutter_meta"
}
