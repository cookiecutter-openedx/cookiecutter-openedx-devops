#!/bin/bash
#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:       june-2022
#
# usage: run this on your EC2 Ubuntu bastion instance
#        to install software packages that are required for use
#        of k8s, kubectl, aws cli, and mysql.
#------------------------------------------------------------------------------

echo "*----------------------------------------------------------------------------*"
echo "* Installing the following:"
echo "* - homebrew"
echo "* - Python 3.8.12"
echo "* - tutor"
echo "* - edx-platform github repository"
echo "* - Open edX system packages for Open edX development"
echo "* - All Open edX python requirements for production and development"
echo "* - MySQL client software"
echo "* - MongoDB client software"
echo "* - aws cli"
echo "* - kubectl"
echo "* - k9s"
echo "* - terraform and terragrunt"
echo "* - helm"
echo "*----------------------------------------------------------------------------*"
echo ""
echo "This password reset initializes a local password value for the ubuntu user so that Homebrew"
echo "can run as Ubuntu while also performing root operations."
echo "select a password value that is easy for your remember."
echo "you can delete the password value, or change it again, after this script completes."
echo "ctl-c to cancel"
sudo passwd ubuntu

sudo apt update && sudo apt upgrade -y

# add more packages that we need for our stuff
# -------------------------------------------------------------
sudo apt install jq mysql-client-8.0 libevent-dev libyaml-dev python3-pip build-essential -y
sudo apt autoremove

sudo snap install kubectl --channel=1.25/stable --classic
sudo snap install yq

pip install --upgrade pyyaml
pip install "tutor[full]"

# install homebrew
# installation time: around 15 minutes
# -------------------------------------------------------------
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/ubuntu/.profile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# install more brew packages related to Open edX administration
# -------------------------------------------------------------
brew install awscli terraform terragrunt helm k9s

# Configure kubectl
# -------------------------------------------------------------
~/scripts/kconfig.sh ${namespace} ${aws_region}

# Install Helm repos
# -------------------------------------------------------------
~/scripts/helm_update.sh

# install mongodb client
# -------------------------------------------------------------
sudo apt install -y software-properties-common gnupg apt-transport-https ca-certificates -y
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 4B7C549A058F8B6B
echo "deb [arch=amd64] http://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
sudo apt update
sudo apt install mongodb-org -y
mongo --version

# install Docker CE
# -------------------------------------------------------------
sudo apt install lsb-release ca-certificates apt-transport-https software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce -y
sudo usermod -aG docker $USER
sudo systemctl enable docker

# install Docker Compose
# -------------------------------------------------------------
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

# report Docker installation results and service status
# -------------------------------------------------------------
sudo systemctl status docker
sudo docker run hello-world

echo "Finished. Note that a reboot is required on the first installation of docker."
