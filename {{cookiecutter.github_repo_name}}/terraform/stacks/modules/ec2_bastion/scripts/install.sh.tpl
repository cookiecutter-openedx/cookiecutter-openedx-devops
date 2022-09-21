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
sudo passwd ubuntu

sudo apt update && sudo apt upgrade -y

# -------------------------------------------------------------
# Add
# match Ubuntu installed packages to those found in the openedx Dockerfile in tutor
# -------------------------------------------------------------
sudo apt update && sudo apt install -y build-essential curl git language-pack-en
LC_ALL=en_US.UTF-8

sudo apt update && \
    sudo apt install -y libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev python-openssl git

# follow tutor steps for installing Python so that we get
# the version, build and install path to exactly match that of Open edX
# -------------------------------------------------------------
PYTHON_VERSION=3.8.12
PYENV_ROOT=/opt/pyenv
sudo git clone https://github.com/pyenv/pyenv $PYENV_ROOT --branch v2.2.2 --depth 1
sudo $PYENV_ROOT/bin/pyenv install $PYTHON_VERSION
#sudo chown -R ubuntu $PYENV_ROOT
#sudo chgrp -R ubuntu $PYENV_ROOT
sudo mkdir /openedx
sudo chown -R ubuntu /openedx
sudo chgrp -R ubuntu /openedx
sudo apt install python3.8-venv
python3 -m venv /openedx/venv
source /openedx/venv/bin/activate


###### Checkout edx-platform code
EDX_PLATFORM_REPOSITORY=https://github.com/openedx/edx-platform
EDX_PLATFORM_VERSION=open-release/nutmeg.master
mkdir -p /openedx/edx-platform && \
    git clone $EDX_PLATFORM_REPOSITORY --branch $EDX_PLATFORM_VERSION --depth 1 /openedx/edx-platform

###### install all Open edX requirements
sudo apt update && sudo apt install -y software-properties-common libmysqlclient-dev libxmlsec1-dev libgeos-dev
sudo apt install python3-dev
pip install setuptools==62.1.0 pip==22.0.4 wheel==0.37.1
cd /openedx/edx-platform
pip install -r ./requirements/edx/base.txt
pip install -r ./requirements/edx/development.txt

# add more packages that we need for our stuff
# -------------------------------------------------------------
sudo apt install jq mysql-client-8.0 libevent-dev libyaml-dev
sudo apt autoremove

sudo snap install kubectl --channel=1.23/stable --classic
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
sudo apt install -y software-properties-common gnupg apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 4B7C549A058F8B6B
echo "deb [arch=amd64] http://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
sudo apt update
sudo apt install mongodb-org
mongo --version

# install Docker CE
# -------------------------------------------------------------
sudo apt install lsb-release ca-certificates apt-transport-https software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce
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
