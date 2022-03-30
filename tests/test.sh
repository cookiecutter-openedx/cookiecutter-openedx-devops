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
GITHUB_BRANCH="eks_fargate"
OUTPUT_FOLDER="/Users/mcdaniel/cookiecutter/"

cookiecutter --checkout $GITHUB_BRANCH \
             --output-dir $OUTPUT_FOLDER \
             --overwrite-if-exists \
             --no-input \
             $GITHUB_REPO \
             global_platform_name=sandbox \
             global_platform_region=ohio \
             global_aws_region=us-east-2 \
             global_account_id=320713933456 \
             global_root_domain=stepwisemath.ai \
             global_aws_route53_hosted_zone_id=Z049210026A5G6XHV84CF \
             global_ec2_ssh_key_name=stepwisemath-ohio \
             environment_name=fargate \
             environment_subdomain=fargate \
             eks_cluster_compute_type=Fargate \
             eks_cluster_load_balancer_type=ALB
