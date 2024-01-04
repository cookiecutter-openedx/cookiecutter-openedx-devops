#!/bin/sh
#------------------------------------------------------------------------------
# written by:   mcdaniel
#               https://lawrencemcdaniel.com
#
# date:         mar-2022
#
# usage:        Re-runs the Cookiecutter for this repository.
#------------------------------------------------------------------------------

GITHUB_REPO="gh:cookiecutter-openedx/cookiecutter-openedx-devops"
GITHUB_BRANCH="{{ cookiecutter.github_release }}"
OUTPUT_FOLDER="../"

if [ -d {{ cookiecutter.github_repo_name }} ]; then
  read -p "Delete all existing Terraform modules in your repository? This is recommended (Y/n) " yn
  case $yn in
    [yY] ) sudo rm -r {{ cookiecutter.github_repo_name }}/terraform;
      echo "removed the current set of Terraform folders in ./{{ cookiecutter.github_repo_name }}/terraform";
      break;;
  esac
fi

cookiecutter --checkout $GITHUB_BRANCH \
            --output-dir $OUTPUT_FOLDER \
            --overwrite-if-exists \
            --no-input \
            $GITHUB_REPO \
            github_repo_name={{ cookiecutter.github_repo_name }} \
            ci_build_theme_repository={{ cookiecutter.ci_build_theme_repository }} \
            ci_deploy_install_credentials_server={{ cookiecutter.ci_deploy_install_credentials_server }} \
            ci_deploy_install_license_manager_service={{ cookiecutter.ci_deploy_install_license_manager_service }} \
            ci_deploy_install_discovery_service={{ cookiecutter.ci_deploy_install_discovery_service }} \
            ci_deploy_install_notes_service={{ cookiecutter.ci_deploy_install_notes_service }} \
            ci_deploy_install_ecommerce_service={{ cookiecutter.ci_deploy_install_ecommerce_service }} \
            global_platform_name={{ cookiecutter.global_platform_name }} \
            global_platform_region={{ cookiecutter.global_platform_region }} \
            global_platform_shared_resource_identifier={{ cookiecutter.global_platform_shared_resource_identifier }} \
            global_services_subdomain={{ cookiecutter.global_services_subdomain }} \
            global_aws_region={{ cookiecutter.global_aws_region }} \
            global_account_id={{ cookiecutter.global_account_id }} \
            global_root_domain={{ cookiecutter.global_root_domain }} \
            global_aws_route53_hosted_zone_id={{ cookiecutter.global_aws_route53_hosted_zone_id }} \
            environment_name={{ cookiecutter.environment_name }} \
            environment_subdomain={{ cookiecutter.environment_subdomain }} \
            environment_add_aws_ses={{ cookiecutter.environment_add_aws_ses }} \
            eks_create_kms_key={{ cookiecutter.eks_create_kms_key }} \
            mysql_instance_class={{ cookiecutter.mysql_instance_class }} \
            mysql_allocated_storage={{ cookiecutter.mysql_allocated_storage }} \
            redis_node_type={{ cookiecutter.redis_node_type }} \
            stack_add_bastion={{ cookiecutter.stack_add_bastion }} \
            stack_add_k8s_dashboard={{ cookiecutter.stack_add_k8s_dashboard }} \
            stack_add_k8s_kubeapps={{ cookiecutter.stack_add_k8s_kubeapps }} \
            stack_add_k8s_karpenter={{ cookiecutter.stack_add_k8s_karpenter }} \
            stack_add_k8s_prometheus={{ cookiecutter.stack_add_k8s_prometheus }} \
            stack_add_remote_mysql={{ cookiecutter.stack_add_remote_mysql }} \
            stack_add_remote_mongodb={{ cookiecutter.stack_add_remote_mongodb }} \
            stack_add_remote_redis={{ cookiecutter.stack_add_remote_redis }} \
            wordpress_add_site={{ cookiecutter.wordpress_add_site }} \
            {% if cookiecutter.stack_add_remote_mongodb == "Y" -%}
            mongodb_instance_type={{ cookiecutter.mongodb_instance_type }} \
            mongodb_allocated_storage={{ cookiecutter.mongodb_allocated_storage }} \
            {% endif %}
