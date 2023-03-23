#!/bin/sh
#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:       aug-2022
#
# usage:      print the login help menu
#------------------------------------------------------------------------------
AWS_CONFIG_FILE=/home/ubuntu/.aws/config
AWS_SHARED_CREDENTIALS_FILE="/home/ubuntu/.aws/credentials"
AWS_REGION=${aws_region}

AWSCLI_VERSION=$(/home/linuxbrew/.linuxbrew/bin/aws --version)
KUBECTL_VERSION=$(/snap/bin/kubectl version --output=json | jq -r '.["clientVersion"].gitVersion as $v | "\($v)"')
HELM_VERSION=$(/home/linuxbrew/.linuxbrew/bin/helm version --short)
BREW_VERSION=$(/home/linuxbrew/.linuxbrew/bin/brew --version)
DOCKER_VERSION=$(/usr/bin/docker --version)
MYSQL_CLIENT_VERSION=$(/usr/bin/mysql --version)
MONGODB_CLIENT_VERSION=$(echo latest)
TUTOR_VERSION=$(/home/ubuntu/.local/bin/tutor --version | cut -f3 -d' ')
PYTHON_VERSION=$(/home/linuxbrew/.linuxbrew/bin/python3 --version)
PIP_VERSION=$(/home/linuxbrew/.linuxbrew/bin/pip3 --version)

TERRAFORM_VERSION=$(cd /home/linuxbrew/.linuxbrew/Cellar/terraform && ls -d *)
TERRAGRUNT_VERSION=$(cd /home/linuxbrew/.linuxbrew/Cellar/terragrunt && ls -d *)
K9S_VERSION=$(cd /home/linuxbrew/.linuxbrew/Cellar/k9s && ls -d *)

AWS_IAM_USER=$(sudo -H -u ubuntu /home/ubuntu/scripts/aws-iam-user.sh)
AWS_EC2_SPOT_PRICE=$(sudo -H -u ubuntu /home/ubuntu/scripts/aws-ec2-spot-prices.sh t3.large report)

printf " Quickstart:\n"
printf "   run install.sh to install preconfigured software packages\n"
printf "   run kconfig.sh ${stack_namespace} ${aws_region} to configure .kube access for k9s\n"
printf " \n"
printf " Open edX Installed Packages\n"
printf '   Python:                  %s\n' "$PYTHON_VERSION"
printf '   pip:                     %s\n' "$PIP_VERSION"
printf "   * edx-platform github repository \n"
printf "   * Open edX system packages for Open edX development \n"
printf "   * All Open edX python requirements for production and development \n"
printf " \n"
printf " Kubernetes\n"
printf '   kubectl:                  %s\n' "$KUBECTL_VERSION"
printf '   k9s:                      %s\n' "$K9S_VERSION"
printf '   helm:                     %s\n' "$HELM_VERSION"
printf "   kconfig.sh                configure kubectl:  \n"
printf "   klog.sh                   download a k8s pod log file \n"
printf "   ksecret.sh                echo a k8s secret to the console \n"
printf "   kubectl                   preconfigured Kubernets command-line interface\n"
printf " \n"
printf " MySQL\n"
printf '   mysql client:             %s\n' "$MYSQL_CLIENT_VERSION"
printf "   root credentials:         ksecret.sh mysql-root ${stack_namespace} \n"
printf "   client connection:        mysql -h mysql.${services_subdomain} -u root -p MYSQL_ROOT_PASSWORD \n"
printf "   openedx-backup-mysql.sh   dump the MySQL databases to the Ubuntu file system \n"
printf "                             and archive to an AWS S3 bucket \n"
printf " \n"
printf " MongoDB\n"
printf '   mongodb client:           %s\n' "$MONGODB_CLIENT_VERSION"
printf "   server connection:        ssh mongodb \n"
printf "   client connection:        mongo 'mongodb://mongodb.${services_subdomain}:27017' \n"
printf "   openedx-backup-mongodb.sh dump the MongoDB databases to the Ubuntu file system \n"
printf "                             and archive to an AWS S3 bucket \n"
printf " tutor\n"
printf '   version:                  %s\n' "$TUTOR_VERSION"
printf "   tutor                     run tutor on the command line \n"
printf "   tutor-developer-build.sh  builds a local development environment \n"
printf "   tutor-reset.sh            completely reinitialize your local Tutor environment \n"
printf " \n"
printf " AWS Infrastructure Management\n"
printf '   aws-cli:                  %s\n' "$AWSCLI_VERSION"
printf '   AWS IAM User:             %s\n' "$AWS_IAM_USER"
printf '   AWS EC2 spot price (USD): t3.large $%s/hour \n' "$AWS_EC2_SPOT_PRICE"
printf '   Terraform:                %s\n' "$TERRAFORM_VERSION"
printf '   Terragrunt:               %s\n' "$TERRAGRUNT_VERSION"
printf " \n"
printf " Other: \n"
printf '   Homebrew:                 %s\n' "$BREW_VERSION"
printf '   Docker CE:                %s\n' "$DOCKER_VERSION"
printf "   helm_update.sh            update the local helm charts repo \n"
printf "   install.sh                install preconfigured software packages \n"
printf "   openedx-install-venv.sh   install edx-platform and all requirements for prod and dev \n"
printf "   update.sh                 update all preconfigured software packages \n"
printf " \n"
