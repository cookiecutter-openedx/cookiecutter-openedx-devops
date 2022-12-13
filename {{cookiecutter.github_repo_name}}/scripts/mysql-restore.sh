#!/bin/bash
#------------------------------------------------------------------------------
# written by:   Lawrence McDaniel
#               https://lawrencemcdaniel.com
#
# date:         sep-2022
#
# usage:        download a mysql tarball backup from AWS S3
#               decompress the contents
#               restore to MySQL host designated in k8s secret
#------------------------------------------------------------------------------

S3_BUCKET="{{ cookiecutter.global_platform_name }}-{{ cookiecutter.global_platform_region }}-{{ cookiecutter.environment_name }}-storage"
BACKUP_KEY="20220912T080001"
BACKUP_TARBALL="openedx-mysql-$BACKUP_KEY.tgz"
BACKUP_FILE="mysql-data-$BACKUP_KEY.sql"

if [ ! -f "~/backups/mysql/$BACKUP_TARBALL" ]; then
    aws s3 cp s3://$S3_BUCKET/backups/$BACKUP_TARBALL ~/backups/mysql/
fi

if [ ! -f "~/backups/mysql/$BACKUP_FILE" ]; then
    echo "decompressing..."
    cd ~/backups/mysql
    tar xvzf $BACKUP_TARBALL
    cd ~
fi

#------------------------------------------------------------------------------
# retrieve the mysql root credentials from k8s secrets. Sets the following environment variables:
#
#    MYSQL_HOST=mysql.{{ cookiecutter.global_root_domain }}
#    MYSQL_PORT=3306
#    MYSQL_ROOT_PASSWORD=******
#    MYSQL_ROOT_USERNAME=root
#
#------------------------------------------------------------------------------
$(ksecret.sh mysql-root academiacentral-global-staging)

echo "importing to $MYSQL_HOST"
mysql -h $MYSQL_HOST  -u $MYSQL_ROOT_USERNAME -p$MYSQL_ROOT_PASSWORD < ~/backups/mysql/$BACKUP_FILE
