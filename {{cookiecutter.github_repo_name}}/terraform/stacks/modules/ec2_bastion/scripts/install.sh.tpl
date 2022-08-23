#!/bin/bash
#---------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:       june-2022
#
# usage: run this on your EC2 Ubuntu bastion instance
#        to install software packages that are required for use
#        of k8s, kubectl, aws cli, and mysql.
#--------------------------------------------------------

sudo passwd ubuntu

sudo apt update
sudo apt upgrade -y
sudo apt install awscli jq mysql-client-8.0
sudo apt autoremove

sudo snap install kubectl --channel=1.23/stable --classic
sudo snap install yq

pip install --upgrade pyyaml
pip install tutor

# install homebrew
# installation time: around 15 minutes
# -------------------------------------------------------------
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/ubuntu/.profile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
sudo apt-get install build-essential
brew install gcc

# install brew packages
# -------------------------------------------------------------
brew install terraform terragrunt helm k9s

# Alternate installation for k9s
# install k9s
# sudo wget -qO- https://github.com/derailed/k9s/releases/download/v0.24.1/k9s_Linux_x86_64.tar.gz | tar zxvf -  -C /tmp/
# sudo mv /tmp/k9s /usr/local/bin


# Configure kubectl
# -------------------------------------------------------------
~/scripts/kconfig.sh ${namespace} ${aws_region}

# Install Helm repos
# -------------------------------------------------------------
~/scripts/helm.sh

# install mongodb client
# -------------------------------------------------------------
sudo apt install -y awscli software-properties-common gnupg apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 4B7C549A058F8B6B
echo "deb [arch=amd64] http://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
sudo apt update
sudo apt install mongodb-org
mongo --version
