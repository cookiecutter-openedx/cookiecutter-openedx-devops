#!/bin/bash
#------------------------------------------------------------------------------
# written by: lawrence mcdaniel
#             https://lawrencemcdaniel.com
#             https://blog.lawrencemcdaniel.com
#
# date:       sep-2022
# usage:      backup MySQL database
#             combine into a single tarball, store in "backups" folders in user directory
#
# reference:  https://github.com/edx/edx-documentation/blob/master/en_us/install_operations/source/platform_releases/ginkgo.rst
#------------------------------------------------------------------------------

S3_BUCKET="SET-ME-PLEASE"
BACKUPS_DIRECTORY="~/backups/"
WORKING_DIRECTORY="~/backup-tmp/"
NUMBER_OF_BACKUPS_TO_RETAIN="10"      # Note: this only regards local storage (ie on the ubuntu server).
                                      # All backups are retained in the S3 bucket forever.

#------------------------------------------------------------------------------
# retrieve the mysql root credentials from k8s secrets. Sets the following environment variables:
#
#    MYSQL_HOST=your-rds-instance.0123456789.eu-west-2.rds.amazonaws.com
#    MYSQL_PORT=3306
#    MYSQL_ROOT_PASSWORD=******
#    MYSQL_ROOT_USERNAME=root
#
#------------------------------------------------------------------------------
$(ksecret.sh mysql-root codlp-global-live)

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

# Begin Backup MySQL databases
#------------------------------------------------------------------------------------------------------------------------
echo "Backing up MySQL databases"
echo "Reading MySQL database names..."
mysql -h ${MYSQL_HOST} -uroot -p"$MYSQL_ROOT_PASSWORD" -ANe "SELECT schema_name FROM information_schema.schemata WHERE schema_name NOT IN ('innodb', 'tmp', 'mysql','sys','information_schema','performance_schema')" > /tmp/db.txt
DBS="--databases $(cat /tmp/db.txt)"
NOW="$(date +%Y%m%dT%H%M%S)"
SQL_FILE="mysql-data-${NOW}.sql"
echo "Dumping MySQL structures..."
mysqldump --set-gtid-purged=OFF --column-statistics=0 -h ${MYSQL_HOST} -uroot -p"$MYSQL_ROOT_PASSWORD" --add-drop-database ${DBS} > ${SQL_FILE}
echo "Done backing up MySQL"

#Tarball our mysql backup file
echo "Compressing MySQL backup into a single tarball archive"
tar -czf ${BACKUPS_DIRECTORY}openedx-mysql-${NOW}.tgz ${SQL_FILE}
sudo chown ubuntu ${BACKUPS_DIRECTORY}openedx-mysql-${NOW}.tgz
sudo chgrp ubuntu ${BACKUPS_DIRECTORY}openedx-mysql-${NOW}.tgz
echo "Created tarball of backup data openedx-mysql-${NOW}.tgz"
# End Backup MySQL databases
#------------------------------------------------------------------------------------------------------------------------


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
