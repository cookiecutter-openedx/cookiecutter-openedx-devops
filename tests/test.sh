#!/bin/sh
#------------------------------------------------------------------------------
# written by:   mcdaniel
#               https://lawrencemcdaniel.com
#
# date:         mar-2022
#
# usage:        Runs the Cookiecutter.
#               Inject your own parameters to override cookiecutter.json defaults
#------------------------------------------------------------------------------

GITHUB_REPO="gh:lpm0073/cookiecutter-openedx-devops"
GITHUB_BRANCH="main"
OUTPUT_FOLDER="/Users/mcdaniel/github/stepwisemath.ai/"

cookiecutter --checkout $GITHUB_BRANCH \
             --output-dir $OUTPUT_FOLDER \
             --overwrite-if-exists \
             --no-input \
             $GITHUB_REPO \
             github_account_name=StepwiseMath \
             github_repo_name=openedx_devops \
             global_platform_name=stepwisemath \
             global_platform_region=mexico \
             global_platform_shared_resource_identifier={{ cookiecutter.global_platform_shared_resource_identifier }} \
             global_aws_region=us-east-2 \
             global_account_id=320713933456 \
             global_root_domain=stepwisemath.ai \
             global_aws_route53_hosted_zone_id=Z0232691KVI7Y7U23HBD \
             environment_name=prod \
             stack_add_bastion=N \
             environment_subdomain=web \
