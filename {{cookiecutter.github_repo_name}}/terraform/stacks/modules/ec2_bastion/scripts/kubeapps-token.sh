#!/bin/bash
#---------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:       jan-2023
#
# usage:      echo the kubeapp sign-in token to the console
#--------------------------------------------------------
kubectl get --namespace kubeapps secret kubeapps-admin -o go-template='{{.data.token | base64decode}}'
