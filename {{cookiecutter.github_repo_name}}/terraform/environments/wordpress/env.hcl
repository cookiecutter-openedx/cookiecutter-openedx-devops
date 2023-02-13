#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
#------------------------------------------------------------------------------
locals {

  # these are benign, but required placeholder variable declarations.
  #
  # More: the 'stack' and open edx 'environment' Terragrunt modules assume
  # the existence of an env.hcl file which contains, among other resources,
  # declarations of share 'environment', 'environment_namespace' variable which
  # are used by all sibling Terragrunt modules in order to enforce consistency.
  #
  # In the case of Wordpress however, 'environment' and 'environment_namespace'
  # are site-specific. Hence, the env.hcl file is not used for these.
  environment               = "wordpress"
  environment_namespace     = "wordpress"

}
