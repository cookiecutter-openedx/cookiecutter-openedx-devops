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

  environment           = "web"
  subdomains            = ["dev", "test"]
  environment_domain    = "${local.environment}.${local.global_vars.locals.root_domain}"
  environment_namespace = "${local.environment}-${local.global_vars.locals.platform_name}-${local.global_vars.locals.platform_region}"


  # AWS infrastructure sizing
                                    # 2 vCPU 4gb
  mongodb_instance_class          = "db.t3.medium"
  mongodb_cluster_size            = 1

                                    # 1 vCPU 2gb
  mysql_instance_class            = "db.t2.small"

                                    # 1 vCPU 1.55gb
  redis_node_type                 = "cache.t2.small"

                                    # 2 vCPU 8gb
  eks_worker_group_instance_type  = "t3.large" 

  tags = {
    Environment = local.environment
  }

}
