#!/bin/bash
#---------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:       june-2022
#
# usage: run this on your MongoDB Ubuntu bastion instance
#        to install required software packages
#
# help:  - view information about devices attached to this instance
#        $ sudo lsblk -f
#
#        - view mounts
#        $ df -h
#--------------------------------------------------------

#
# mount the detachable EBS volume to mongodb's data directory.
# It is recommended that MongoDB uses only the ext4 or XFS filesystems
# for on-disk database data. ext3 should be avoided due to its poor
# pre-allocation performance.
#
# If you're using WiredTiger (MongoDB 3.0+) as a storage engine,
# it is strongly advised that you ONLY use XFS due to serious stability issues on ext4.
if [ ! -d "/var/lib/mongodb" ]
then
    # format the volue
    sudo mkfs -t xfs /dev/nvme1n1

    sudo mkdir /var/lib/mongodb -p
fi

# mount the volume
sudo mount /dev/nvme1n1 /var/lib/mongodb

echo "mounted volume /dev/nvme1n1"
df -h

#
# Install Mongodb 4.2.x
# https://askubuntu.com/questions/842592/apt-get-fails-on-16-04-or-18-04-installing-mongodb

sudo apt update
sudo apt upgrade -y
sudo apt install -y awscli software-properties-common gnupg apt-transport-https ca-certificates -y
sudo apt autoremove

# install mongodb
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 4B7C549A058F8B6B
echo "deb [arch=amd64] http://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
sudo apt update
sudo apt install mongodb-org -y

sudo chown -R mongodb /var/lib/mongodb
sudo chgrp -R mongodb /var/lib/mongodb

sudo mkdir /var/log/mongodb/
sudo chown -R mongodb /var/log/mongodb
sudo chgrp -R mongodb /var/log/mongodb

sudo systemctl enable mongod.service
sudo systemctl start mongod.service
sudo systemctl status mongod.service

# install anything else we need
