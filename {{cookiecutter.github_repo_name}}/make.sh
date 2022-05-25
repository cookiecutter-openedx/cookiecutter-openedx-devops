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
             mysql_instance_class={{ cookiecutter.mysql_instance_class }} \
             mysql_allocated_storage={{ cookiecutter.mysql_allocated_storage }} \
             redis_node_type={{ cookiecutter.redis_node_type }}
