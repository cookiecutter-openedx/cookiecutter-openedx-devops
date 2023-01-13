#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2022
#
# usage: create environment-level parameters, exposed to all
#        Terragrunt modules in this enironment.
#------------------------------------------------------------------------------
locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  environment               = "{{ cookiecutter.environment_name }}"
  environment_subdomain     = "{{ cookiecutter.environment_subdomain }}"
  environment_domain        = "${local.environment_subdomain}.${local.global_vars.locals.root_domain}"
  environment_namespace     = "${local.global_vars.locals.platform_name}-${local.global_vars.locals.platform_region}-${local.environment}"
  shared_resource_namespace = local.global_vars.locals.shared_resource_namespace
  db_prefix                 = replace(replace("${local.global_vars.locals.platform_name}_${local.environment}", ".", ""), "-", "")

  # AWS instance sizing
  redis_node_type      = "{{ cookiecutter.redis_node_type }}"

  tags = merge(
    local.global_vars.locals.tags,
    {
      "cookiecutter/environment"                = local.environment
      "cookiecutter/environment_subdomain"      = local.environment_subdomain
      "cookiecutter/environment_domain"         = local.environment_domain
      "cookiecutter/environment_namespace"      = local.environment_namespace
      "cookiecutter/shared_resource_namespace"  = local.shared_resource_namespace
    }
  )
}
