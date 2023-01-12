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

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.10.1/cert-manager.crds.yaml

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo add karpenter https://charts.karpenter.sh/
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add cowboysysop https://cowboysysop.github.io/charts/
helm repo add jetstack https://charts.jetstack.io
helm repo update
