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
S3_BUCKET="{{ cookiecutter.global_platform_name }}-{{ cookiecutter.global_platform_region }}-{{ cookiecutter.environment_name }}-storage"
MONGODB_HOST="mongodb.{{ cookiecutter.global_root_domain }}:27017"

BACKUP_KEY="20220912T080001"

BACKUP_TARBALL="openedx-mongo-$BACKUP_KEY.tgz"
BACKUP_FILE="mongo-dump-$BACKUP_KEY"

if [ ! -f "~/backups/mongodb/$BACKUP_TARBALL" ]; then
    #aws s3 cp s3://$S3_BUCKET/backups/$BACKUP_TARBALL ~/backups/mongodb/ --recursive
    aws s3 cp s3://$S3_BUCKET/backups/$BACKUP_TARBALL ~/backups/mongodb/
fi

if [ ! -f "~/backups/mongodb/$BACKUP_FILE" ]; then
    echo "decompressing..."
    cd ~/backups/mongodb
    tar xvzf $BACKUP_TARBALL
    cd ~
fi

mongo
use {{ cookiecutter.global_platform_name }}_{{ cookiecutter.environment_name }}_edx;
db.dropDatabase();
exit

mongorestore -d {{ cookiecutter.global_platform_name }}_{{ cookiecutter.environment_name }}_edx ~/backups/mongodb/mongo-dump-${BACKUP_KEY}/edxapp --host $MONGODB_HOST
