#!/bin/bash
#---------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:       june-2022
#
# usage:      sets the current k8s context.
#             you only need this if you use kubectl
#             with more than one kubuernetes cluster
#--------------------------------------------------------

if [ $# == 2 ]; then
    echo "setting kubectl context to $1 namespace $2"
    kubectl config use-context $1
    kubectl config set-context --current --namespace=$2
else
    echo "kcontext.sh - set Kubernetes context and namespace."
    echo "Usage: ./kcontext.sh context namespace"
    exit 1
fi
