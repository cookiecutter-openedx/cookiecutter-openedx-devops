#!/bin/bash
#---------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:       june-2022
#
# usage: run this on your local computer to configure
#        kubectl with the AWS EKS kubernetes cluster
#        configuration credentials that are
#        located here:
#        https://{{ cookiecutter.global_aws_region }}.console.aws.amazon.com/eks/home?region={{ cookiecutter.global_aws_region }}#/clusters/{{ cookiecutter.global_platform_name }}-{{ cookiecutter.global_platform_region }}-{{ cookiecutter.global_platform_shared_resource_identifier }}
#--------------------------------------------------------

if [ $# == 2 ]; then
    echo "configure kubectl cluster $1 in AWS region $2"

    aws eks --region $2 update-kubeconfig --name $1 --alias $1

else
    echo "kconfig.sh - kubectl config"
    echo "Usage: ./kconfig.sh eks-cluster-name aws-region "
    exit 1
fi
