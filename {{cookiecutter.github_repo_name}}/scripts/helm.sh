#!/bin/bash
#---------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:       Auge-2022
#
# usage: run this on your local computer to configure
#        a helm repo with the helm charts that are used
#        by this Cookiecutter.
#--------------------------------------------------------

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo add jetstack https://charts.jetstack.io/
helm repo add karpenter https://charts.karpenter.sh/
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
