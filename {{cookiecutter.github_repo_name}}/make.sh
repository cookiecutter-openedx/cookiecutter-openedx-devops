#!/bin/sh
#------------------------------------------------------------------------------
# written by:   mcdaniel
#               https://lawrencemcdaniel.com
#
# date:         mar-2022
#
# usage:        Re-runs the Cookiecutter for this repository.
#------------------------------------------------------------------------------

GITHUB_REPO="gh:lpm0073/cookiecutter-openedx-devops"
GITHUB_BRANCH="main"
OUTPUT_FOLDER="../"

cookiecutter --checkout $GITHUB_BRANCH \
             --output-dir $OUTPUT_FOLDER \
             --overwrite-if-exists \
             --no-input \
             $GITHUB_REPO \
             ci_deploy_install_credentials_server={{ cookiecutter.ci_deploy_install_credentials_server }} \
             ci_deploy_install_license_manager_service={{ cookiecutter.ci_deploy_install_license_manager_service }} \
             ci_deploy_install_discovery_service={{ cookiecutter.ci_deploy_install_discovery_service }} \
             ci_deploy_install_mfe_service={{ cookiecutter.ci_deploy_install_mfe_service }} \
             ci_deploy_install_notes_service={{ cookiecutter.ci_deploy_install_notes_service }} \
             ci_deploy_install_ecommerce_service={{ cookiecutter.ci_deploy_install_ecommerce_service }} \
             global_platform_name={{ cookiecutter.global_platform_name }} \
             global_platform_region={{ cookiecutter.global_platform_region }} \
             global_aws_region={{ cookiecutter.global_aws_region }} \
             global_account_id={{ cookiecutter.global_account_id }} \
             global_root_domain={{ cookiecutter.global_root_domain }} \
             global_aws_route53_hosted_zone_id={{ cookiecutter.global_aws_route53_hosted_zone_id }} \
             environment_name={{ cookiecutter.environment_name }} \
             environment_subdomain={{ cookiecutter.environment_subdomain }} \
             eks_worker_group_instance_type={{ cookiecutter.eks_worker_group_instance_type }} \
             eks_worker_group_min_size={{ cookiecutter.eks_worker_group_min_size }} \
             eks_worker_group_max_size={{ cookiecutter.eks_worker_group_max_size }} \
             eks_worker_group_desired_size={{ cookiecutter.eks_worker_group_desired_size }} \
             eks_karpenter_group_instance_type={{ cookiecutter.eks_karpenter_group_instance_type }} \
             eks_karpenter_group_min_size={{ cookiecutter.eks_karpenter_group_min_size }} \
             eks_karpenter_group_max_size={{ cookiecutter.eks_karpenter_group_max_size }} \
             eks_karpenter_group_desired_size={{ cookiecutter.eks_karpenter_group_desired_size }} \
             mysql_instance_class={{ cookiecutter.mysql_instance_class }} \
             mysql_allocated_storage={{ cookiecutter.mysql_allocated_storage }} \
             redis_node_type={{ cookiecutter.redis_node_type }} \
             stack_add_bastion={{ cookiecutter.stack_add_bastion }} \
             stack_add_remote_mongodb={{ cookiecutter.stack_add_remote_mongodb }} \
             {% if cookiecutter.stack_add_remote_mongodb == "Y" -%}
             mongodb_instance_type={{ cookiecutter.mongodb_instance_type }} \
             mongodb_allocated_storage={{ cookiecutter.mongodb_allocated_storage }} \
             {% endif %}
