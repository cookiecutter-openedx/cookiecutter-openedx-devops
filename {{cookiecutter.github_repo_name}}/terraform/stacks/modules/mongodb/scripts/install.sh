#!/bin/bash
#---------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:       aug-2022
#
# usage: run this on your MongoDB Ubuntu bastion instance
#        to install required software packages
#--------------------------------------------------------

#
# mount the detachable EBS volume to mongodb's data directory.
if [ ! -d "/var/lib/mongodb" ]
then
sudo mkfs -t ext4 /dev/nvme1n1
sudo mkdir /var/lib/mongodb -p
sudo mount /dev/nvme1n1 /var/lib/mongodb
fi

#
# Install Mongodb 4.2.x
# https://askubuntu.com/questions/842592/apt-get-fails-on-16-04-or-18-04-installing-mongodb

sudo apt update
sudo apt upgrade -y
sudo apt install -y awscli software-properties-common gnupg apt-transport-https ca-certificates
sudo apt autoremove

# install mongodb
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 4B7C549A058F8B6B
echo "deb [arch=amd64] http://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
sudo apt update
sudo apt install mongodb-org

sudo chown -R mongodb /var/lib/mongodb
sudo chgrp -R mongodb /var/lib/mongodb

sudo systemctl enable mongod.service
sudo systemctl start mongod.service

# install anything else we need
