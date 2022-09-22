#!/bin/bash
#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:       sep-2022
#
# usage:      install edx-platform and all requirements for prod and dev
#------------------------------------------------------------------------------

echo "*----------------------------------------------------------------------------*"
echo "* Installing the following:"
echo "* - edx-platform github repository"
echo "* - Open edX system packages for Open edX development"
echo "* - All Open edX python requirements for production and development"
echo "*----------------------------------------------------------------------------*"

PYTHON_VERSION=3.8.12
EDX_PLATFORM_REPOSITORY=https://github.com/openedx/edx-platform
EDX_PLATFORM_VERSION=open-release/nutmeg.master

sudo apt update && sudo apt upgrade -y

# -------------------------------------------------------------
# Add
# match Ubuntu installed packages to those found in the openedx Dockerfile in tutor
# reference: https://github.com/overhangio/tutor/blob/master/tutor/templates/build/openedx/Dockerfile#L5
# -------------------------------------------------------------
sudo apt update && sudo apt install -y build-essential curl git language-pack-en
LC_ALL=en_US.UTF-8

sudo apt update && \
    sudo apt install -y libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev python-openssl git

# follow tutor steps for installing Python so that we get
# the version, build and install path to exactly match that of Open edX
# reference: https://github.com/overhangio/tutor/blob/master/tutor/templates/build/openedx/Dockerfile#L12
# -------------------------------------------------------------
PYENV_ROOT=/opt/pyenv
sudo git clone https://github.com/pyenv/pyenv $PYENV_ROOT --branch v2.2.2 --depth 1
sudo $PYENV_ROOT/bin/pyenv install $PYTHON_VERSION
sudo mkdir /openedx
sudo chown -R ubuntu /openedx
sudo chgrp -R ubuntu /openedx
sudo apt install python3.8-venv
python3 -m venv /openedx/venv
source /openedx/venv/bin/activate

# launch this virtual environment on ubuntu shell logins
echo 'source /openedx/venv/bin/activate' >> /home/ubuntu/.profile


###### Checkout edx-platform code
mkdir -p /openedx/edx-platform && \
    git clone $EDX_PLATFORM_REPOSITORY --branch $EDX_PLATFORM_VERSION --depth 1 /openedx/edx-platform

###### install all Open edX requirements
# reference: https://github.com/overhangio/tutor/blob/master/tutor/templates/build/openedx/Dockerfile#L73
sudo apt update && sudo apt install -y software-properties-common libmysqlclient-dev libxmlsec1-dev libgeos-dev
sudo apt install python3-dev
pip install setuptools==62.1.0 pip==22.0.4 wheel==0.37.1
cd /openedx/edx-platform

# reference: https://github.com/overhangio/tutor/blob/master/tutor/templates/build/openedx/Dockerfile#L88
pip install -r ./requirements/edx/base.txt
pip install -r ./requirements/edx/development.txt

echo "Finished installing edx-platform and requirements"
