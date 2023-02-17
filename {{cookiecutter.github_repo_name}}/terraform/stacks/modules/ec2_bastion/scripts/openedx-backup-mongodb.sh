#!/bin/bash
#---------------------------------------------------------
# written by: lawrence mcdaniel
#             https://lawrencemcdaniel.com
#             https://blog.lawrencemcdaniel.com
#
# date:       sep-2022
# usage:      backup MongoDB data stores
#             combine into a single tarball, store in "backups" folders in user directory
#
# reference:  https://github.com/edx/edx-documentation/blob/master/en_us/install_operations/source/platform_releases/ginkgo.rst
#
# mongo 'mongodb://${MONGODB_HOST}:27017'
#---------------------------------------------------------

# ensure that cron can find our aws cli configuration
AWS_CONFIG_FILE=/home/ubuntu/.aws/config
AWS_REGION={{ cookiecutter.global_aws_region }}

# do not change these
BASE_BACKUPS_DIRECTORY="/home/ubuntu/backups/"
BACKUPS_DIRECTORY="${BASE_BACKUPS_DIRECTORY}/mongodb/"
WORKING_DIRECTORY="/home/ubuntu/backup-tmp/"

# AWS S3 Bucket for remote storage
S3_BUCKET="{{ cookiecutter.global_platform_name }}-{{ cookiecutter.global_platform_region }}-{{ cookiecutter.environment_name }}-backup"
NUMBER_OF_BACKUPS_TO_RETAIN="10"      # Note: this only regards local storage (ie on the ubuntu server).
                                      # All backups are retained in the S3 bucket forever.
                                      # BE AWARE: AWS S3 monthly costs will grow unbounded.
                                      # You need to monitor the size of the S3 bucket and prune
                                      # old backups as you deem appropriate.
NOW="$(date +%Y%m%dT%H%M%S)"

#------------------------------------------------------------------------------
# retrieve the mongo admin credentials from k8s secrets. Sets the following environment variables:
#
# MONGODB_ADMIN_PASSWORD: *******
# MONGODB_ADMIN_USERNAME: admin
# MONGODB_HOST: mongodb.{{ cookiecutter.global_platform_shared_resource_identifier }}.{{ cookiecutter.global_root_domain }}
# MONGODB_PORT: "27017"
#
#------------------------------------------------------------------------------
$(ksecret.sh mongodb-admin {{ cookiecutter.global_platform_name }}-{{ cookiecutter.global_platform_region }}-{{ cookiecutter.global_platform_shared_resource_identifier }})

#Check to see if a working folder exists. if not, create it.
if [ ! -d ${WORKING_DIRECTORY} ]; then
    mkdir ${WORKING_DIRECTORY}
    echo "created backup working folder ${WORKING_DIRECTORY}"
fi

#Check to see if anything is currently in the working folder. if so, delete it all.
if [ -f "$WORKING_DIRECTORY/*" ]; then
  sudo rm -r "$WORKING_DIRECTORY/*"
fi

#Check to see if a base backups/ folder exists. if not, create it.
if [ ! -d ${BASE_BACKUPS_DIRECTORY} ]; then
    mkdir ${BASE_BACKUPS_DIRECTORY}
    echo "created backups folder ${BASE_BACKUPS_DIRECTORY}"
fi

#Check to see if a backups/mongodb/ folder exists. if not, create it.
if [ ! -d ${BACKUPS_DIRECTORY} ]; then
    mkdir ${BACKUPS_DIRECTORY}
    echo "created backups folder ${BACKUPS_DIRECTORY}"
fi


cd ${WORKING_DIRECTORY}

# Begin Backup Mongo
#------------------------------------------------------------------------------------------------------------------------

echo "Backing up MongoDB"
mongodump --host ${MONGODB_HOST} --out mongo-dump-${NOW}
echo "Done backing up MongoDB"

#Tarball all of our backup files
echo "Compressing backups into a single tarball archive"
tar -czf ${BACKUPS_DIRECTORY}openedx-mongo-${NOW}.tgz mongo-dump-${NOW}

# ensure that ubuntu owns these files, regardless of who runs this script
sudo chown ubuntu ${BACKUPS_DIRECTORY}openedx-mongo-${NOW}.tgz
sudo chgrp ubuntu ${BACKUPS_DIRECTORY}openedx-mongo-${NOW}.tgz
echo "Created tarball of backup data openedx-mongo-${NOW}.tgz"
# End Backup Mongo
#------------------------------------------------------------------------------------------------------------------------

#Prune the Backups/ folder by eliminating all but the 30 most recent tarball files
echo "Pruning the local backup folder archive"
if [ -d ${BACKUPS_DIRECTORY} ]; then
  cd ${BACKUPS_DIRECTORY}
  ls -1tr | head -n -${NUMBER_OF_BACKUPS_TO_RETAIN} | xargs -d '\n' rm -f --
fi

#Remove the working folder
echo "Cleaning up"
sudo rm -r ${WORKING_DIRECTORY}

echo "Sync backup to AWS S3 backup folder"
aws s3 sync ${BASE_BACKUPS_DIRECTORY} s3://${S3_BUCKET}/backups
echo "Done!"
