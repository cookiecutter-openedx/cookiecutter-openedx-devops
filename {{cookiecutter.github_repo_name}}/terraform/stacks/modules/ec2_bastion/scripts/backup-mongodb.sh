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

MONGODB_HOST="mongodb:27017"
S3_BUCKET="SET-ME-PLEASE"

BACKUPS_DIRECTORY="/home/ubuntu/backups/"
WORKING_DIRECTORY="/home/ubuntu/backup-tmp/"
NUMBER_OF_BACKUPS_TO_RETAIN="10"      #Note: this only regards local storage (ie on the ubuntu server). All backups are retained in the S3 bucket forever.

#Check to see if a working folder exists. if not, create it.
if [ ! -d ${WORKING_DIRECTORY} ]; then
    mkdir ${WORKING_DIRECTORY}
    echo "created backup working folder ${WORKING_DIRECTORY}"
fi

#Check to see if anything is currently in the working folder. if so, delete it all.
if [ -f "$WORKING_DIRECTORY/*" ]; then
  sudo rm -r "$WORKING_DIRECTORY/*"
fi

#Check to see if a backups/ folder exists. if not, create it.
if [ ! -d ${BACKUPS_DIRECTORY} ]; then
    mkdir ${BACKUPS_DIRECTORY}
    echo "created backups folder ${BACKUPS_DIRECTORY}"
fi


cd ${WORKING_DIRECTORY}

# Begin Backup Mongo
#------------------------------------------------------------------------------------------------------------------------

echo "Backing up MongoDB"
for db in edxapp cs_comment_service_development; do
    echo "Dumping Mongo db ${db}..."
    mongodump --host ${MONGODB_HOST}
done
echo "Done backing up MongoDB"

#Tarball all of our backup files
echo "Compressing backups into a single tarball archive"
tar -czf ${BACKUPS_DIRECTORY}openedx-mongo-${NOW}.tgz mongo-dump-${NOW}
sudo chown root ${BACKUPS_DIRECTORY}openedx-mongo-${NOW}.tgz
sudo chgrp root ${BACKUPS_DIRECTORY}openedx-mongo-${NOW}.tgz
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
aws s3 sync ${BACKUPS_DIRECTORY} s3://${S3_BUCKET}/backups
echo "Done!"
