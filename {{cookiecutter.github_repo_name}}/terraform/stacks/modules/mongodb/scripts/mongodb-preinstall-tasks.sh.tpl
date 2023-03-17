#!/bin/bash
#---------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:       aug-2022
#
# usage: MongoDB pre-installation tasks on Bastion.
#--------------------------------------------------------

# ensure that we have a top-level tmp folder
echo creating /tmp/cookiecutter
mkdir -p /tmp/cookiecutter

# get rid of any legacy tmp files for mongodb
rm -rf /tmp/cookiecutter/mongodb

# recreate the mongodb temp folder.
# at this point we are now certain that this folder exists and that it's empty
echo creating /tmp/cookiecutter/mongodb
mkdir -p /tmp/cookiecutter/mongodb

# ensure that no legacy private key exists for the mongodb server
rm -f ~/.ssh/${ssh_private_key_filename}

# FIX NOTE: figure out how to avoid completely removing known_hosts
rm -f ~/.ssh/known_hosts
touch ~/.ssh/known_hosts

# setup the tmp working folders for mongodb configuration
echo creating /tmp/cookiecutter/mongodb/.aws
mkdir /tmp/cookiecutter/mongodb/.aws

echo creating /tmp/cookiecutter/mongodb/scripts
mkdir /tmp/cookiecutter/mongodb/scripts

echo creating /tmp/cookiecutter/mongodb/etc
mkdir /tmp/cookiecutter/mongodb/etc
