#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: create environment-level parameters, exposed to all
#        Terragrunt modules in this environment.
#------------------------------------------------------------------------------
locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  environment               = "wordpress"
  environment_namespace     = "wordpress"

}
