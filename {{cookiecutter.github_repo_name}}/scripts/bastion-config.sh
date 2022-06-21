#!/bin/bash
#---------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:       june-2022
#
# usage: run this on your EC2 Ubuntu bastion instance
#        to install software packages that are required for use
#        of k8s, kubectl, aws cli, and mysql
#--------------------------------------------------------
sudo apt update
sudo apt upgrade -y
sudo apt install awscli jq mysql-client-8.0
sudo apt autoremove

sudo snap install kubectl --channel=1.23/stable --classic
sudo snap install yq

pip install --upgrade pyyaml
pip install tutor
