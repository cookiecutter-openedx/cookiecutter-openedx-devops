#!/bin/bash
#---------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:       aug-2022
#
# usage: update all installed software.
#--------------------------------------------------------

# update standard ubuntu packages
sudo apt update
sudo apt upgrade -y

# update anything installed with brew: terraform terragrunt helm k9s
brew update
brew upgrade

# update helm charts
helm.sh

# update Kubernetes kubectl config
kconfig.sh ${namespace} ${aws_region}
