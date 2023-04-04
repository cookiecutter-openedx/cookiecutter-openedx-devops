# -----------------------------------------------------------------------------
# written by:   lawrence mcdaniel
#               https://lawrencemcdaniel.com
#
# date:         mar-2023
#
# usage:        migrate data from a legacy Open edX platform (Koa, Lilic or Maple)
#               to Nutmeg.
#
#               Assumes remote storage services are accessible in both
#               the source and target platforms.
#
#               Assumes that the mysql and mongo backup files were created using
#               these cookiecutter-generated bash scripts:
#                   - https://github.com/cookiecutter-openedx/cookiecutter-openedx-devops/blob/main/%7B%7Bcookiecutter.github_repo_name%7D%7D/scripts/openedx-backup-mysql.sh
#                   - https://github.com/cookiecutter-openedx/cookiecutter-openedx-devops/blob/main/%7B%7Bcookiecutter.github_repo_name%7D%7D/scripts/openedx-backup-mongodb.sh
#               Note that you can use these Jinja templates to create working
#               scripts regardless of whether your source platform uses the cookiecutter
#
#               Assumes that the target platform is
#               - deployed via tutor
#               - version Nutmeg or later.
#               - created via Cookiecutter. this is helpful but not required.
#               - kubernetes based
#
#               migrates the following:
#               - MySQL edxapp db to tutor's openedx db
#               - MongoDB edxapp db to tutor's openedx db
#               - AWS S3 storage bucket contents
# see also:
#   - https://discuss.openedx.org/t/how-to-move-through-tutor-versions-part-ii/9574/9
#   - https://discuss.openedx.org/t/upgrading-koa-to-nutmeg-why-dont-courses-appear/8287
#   - https://openedx.atlassian.net/wiki/spaces/COMM/pages/3249438723/How+to+migrate+from+a+native+deployment+to+a+tutor+deployment+of+the+Open+edX+platform
#
# Infrastructure notes
#
# running on a Cookiecutter Bastion EC2 instance.
# see: https://github.com/cookiecutter-openedx/cookiecutter-openedx-devops/tree/main/%7B%7Bcookiecutter.github_repo_name%7D%7D/terraform/stacks/modules/ec2_bastion
#
# size:     t3.xlarge (4 vCPU / 16Gib memory).
#           500Gib standard EBS drive volume
#           around 150Gib was in use at the end of the migration process
#           Note that smaller EC2 instance sizes failed for various reasons.
#
# it's a good idea to run 'df' at the onset of this procedure to take note of
# your available drive space.
# -----------------------------------------------------------------------------

# local environment variables
# -----------------------------------------------------------------------------
LOCAL_BACKUP_PATH="/home/ubuntu/migration/backups/"             # remote backup files from AWS S3 are sync'd to this location
LOCAL_TUTOR_DATA_DIRECTORY="$(tutor config printroot)/data/"
LOCAL_TUTOR_MYSQL_ROOT_PASSWORD=$(tutor config printvalue MYSQL_ROOT_PASSWORD)
LOCAL_TUTOR_MYSQL_ROOT_USERNAME=$(tutor config printvalue MYSQL_ROOT_USERNAME)

# source data
# -----------------------------------------------------------------------------
SOURCE_MYSQL_FILE_PREFIX="openedx-mysql-"                       # example file: openedx-mysql-20230324T000001.tgz
SOURCE_MYSQL_TAG="20230324T000001"                              # a timestamp identifier suffixed to all mysql backup files.


SOURCE_MONGODB_PREFIX="mongo-dump-"                             # example file: mongo-dump-20230324T020001
SOURCE_MONGODB_TAG="20230324T020001"                            # a timestamp identifier suffixed to all mongodb backup files.


SOURCE_AWS_S3_BACKUP_BUCKET="AWS-S3-BUCKET-NAME"                # expecting to find folders ./backups/mysql and ./backups/mongodb inside this bucket
SOURCE_AWS_S3_STORAGE_BUCKET_SOURCE="AWS-S3-BUCKET-NAME"        # assumes that your source platform uses AWS S3 for all storages

# target data
# -----------------------------------------------------------------------------
TARGET_AWS_S3_STORAGE_BUCKET="AWS-S3-BUCKET-NAME"
TARGET_KUBERNETES_OPENEDX_NAMESPACE="SET-ME-PLEASE"             # the k8s namespace to which your target environment is deployed
TARGET_KUBERNETES_SERVICE_NAMESPACE="SET-ME-PLEASE"             # the k8s namespace for your shared infrastructure services: mysql, mongo, redis, etcetera

# 1. Prepare the local environment
# -------------------------------
if [ ! -d "/home/ubuntu/migration" ]; then
    mkdir /home/ubuntu/migration
    echo "created directory /home/ubuntu/migration"
fi
if [ ! -d "/home/ubuntu/migration/backups" ]; then
    mkdir /home/ubuntu/migration/backups
    echo "created directory /home/ubuntu/migration/backups"
fi
if [ ! -d "/home/ubuntu/migration/upgraded" ]; then
    mkdir /home/ubuntu/migration/upgraded
    echo "created directory /home/ubuntu/migration/upgraded"
fi

# 2 sync the data migration backups folder contents to the local file system
# -------------------------------
aws s3 sync "s3://${SOURCE_AWS_S3_BACKUP_BUCKET}/backups/" /home/ubuntu/migration/backups/
tar xvzf "${LOCAL_BACKUP_PATH}mysql/${SOURCE_MYSQL_FILE_PREFIX}${SOURCE_MYSQL_TAG}.tgz" --directory "${LOCAL_BACKUP_PATH}mysql/"

# 3. sync the AWS S3 storage of the legacy platform to the target platform's bucket
# -------------------------------
aws s3 sync s3://$SOURCE_AWS_S3_STORAGE_BUCKET_SOURCE s3://$TARGET_AWS_S3_STORAGE_BUCKET

# take care of any storage folder structure transformations for block storage, video, grades, etcetera
aws s3 mv s3://$TARGET_AWS_S3_STORAGE_BUCKET/some-poorly-placed-folder/submissions_attachments/ s3://$TARGET_AWS_S3_STORAGE_BUCKET/submissions_attachments/ --recursive
aws s3 mv s3://$TARGET_AWS_S3_STORAGE_BUCKET/some-poorly-placed-folder/grades-download/ s3://$TARGET_AWS_S3_STORAGE_BUCKET/grades-download/ --recursive

# -----------------------------------------------------------------------------
# 4. initialize Docker and tutor environments
#
# Note that in my case I had to run this procedure a half dozen times
# until it actually worked. If you're as unfortunate as me then you'll
# potentially need to get your ubuntu instance back to a pristine state
# depending on what went wrong on your most recent failed attempt.
#
# This is how to "reset" your Ubuntu environment to pristine.
#
# - shut down and remove any running Docker containers
# - delete any existing Docker volumes
# - if tutor is currently installed then uninstall it and all of its modules
# -----------------------------------------------------------------------------
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker rmi $(docker images -a -q)
docker volume prune

sudo rm -rf "$(tutor config printroot)"
pip uninstall tutor-openedx
sudo rm "$(which tutor)"
pip uninstall tutor -y
pip uninstall tutor-xqueue -y
pip uninstall tutor-webui -y
pip uninstall tutor-richie -y
pip uninstall tutor-notes -y
pip uninstall tutor-minio -y
pip uninstall tutor-mfe -y
pip uninstall tutor-license -y
pip uninstall tutor-forum -y
pip uninstall tutor-ecommerce -y
pip uninstall tutor-discovery -y
pip uninstall tutor-android -y

# 5. Setup your local tutor environment
#
# choose the initial version of tutor to install.
# you should select the version of tutor that natively installs
# the open edx version of your immediate next upgrade. for example,
# if you're currently running Koa then you should should install
# tutor 12.2.0 which natively installs Lilac, the immediate next version
# of open edx after Koa.
#
# keep in mind that during this step you're creating a throwaway local
# instance of open edx that effectively is a bi-product of you getting
# your local tutor environment into the state that you need so that you can
# begin migrating your data.
#
# -----------------------------------------------------------------------------
# see: https://discuss.openedx.org/t/how-to-move-through-tutor-versions/6618
#      https://discuss.openedx.org/t/how-to-move-through-tutor-versions-part-ii/9574
#
# Curr edX            will
# Version   tutor     upgrade to
# --------  --------- -------------
# Juniper   11.3.0    → Koa
# Koa       12.2.0    → Lilac
# Lilac     13.3.1    → Maple
# Maple     14.2.4    → Nutmeg
#
# note: prior versions of tutor were yanked, and so the earliest version you can migrate to is Lilac
#
#
# run only if you're migrating from juniper
pip install "tutor[full]==11.3.0"       # installs/upgrades to Koa by default
tutor local quickstart

# run only if you're migrating from koa
pip install "tutor[full]==12.2.0"       # installs/upgrades to Lilac by default
tutor local quickstart

# run only if you're migrating from lilac
pip install "tutor[full]==13.3.1"       # installs/upgrades to Maple by default
tutor local quickstart

# run only if you're migrating from maple.3
pip install "tutor[full]==14.2.4"       # installs/upgrades to Nutmeg by default
tutor local quickstart

# 6. modify the db name inside your source mysql dump file
# -----------------------------------------------------------------------------
# If your source data comes from a native build (presumably Lilac or earlier)
# then the mysql database will be named 'edxapp', and needs to be renamed to
# 'openedx'
#
# Use vi/vim to search-replace the source database name 'edxapp' for the Tutor
# database name 'openedx'.
#
vim ${LOCAL_BACKUP_PATH}mysql/mysql-data-${SOURCE_MYSQL_TAG}.sql
# usage:
#   :%s/edxapp/openedx/g
# -----------------------------------------------------------------------------


# 7. Import your legacy MySQL data
# -----------------------------------------------------------------------------
docker exec -i tutor_local_mysql_1 sh -c 'exec mysql -u$LOCAL_TUTOR_MYSQL_ROOT_USERNAME -p$LOCAL_TUTOR_MYSQL_ROOT_PASSWORD -e "DROP DATABASE openedx;"'
docker exec -i tutor_local_mysql_1 sh -c 'exec mysql -u$LOCAL_TUTOR_MYSQL_ROOT_USERNAME -p$LOCAL_TUTOR_MYSQL_ROOT_PASSWORD' < "${LOCAL_BACKUP_PATH}mysql/mysql-data-${SOURCE_MYSQL_TAG}.sql"

# 8. take care of any Tutor-specific conflicts that might exist in your MySQL data
# in my case there was a username name conflict with a service account user that tutor creates.
#
# You would encounter conflicts of this nature the first time you run 'tutor local launch' after having restored your MySQL database.
# -----------------------------------------------------------------------------


# 9. Import your legacy MongoDB
# -----------------------------------------------------------------------------
if [ -d "${LOCAL_TUTOR_DATA_DIRECTORY}mongodb/backup" ]; then
    sudo rm -r "${LOCAL_TUTOR_DATA_DIRECTORY}mongodb/backup"
    echo "pruned backup working folder "${LOCAL_TUTOR_DATA_DIRECTORY}mongodb/backup""
fi

#
# move the source MongoDB backup data into a part of the Ubuntu file
# system where Tutor's mongo service Docker container can see it.
# NOTE: a 20Gib dump took anywhere from 5 to 10 minutes to copy
#
sudo mv "${LOCAL_BACKUP_PATH}mongodb/${SOURCE_MONGODB_PREFIX}${SOURCE_MONGODB_TAG}" ${LOCAL_TUTOR_DATA_DIRECTORY}mongodb/
sudo mv ${LOCAL_TUTOR_DATA_DIRECTORY}mongodb/${SOURCE_MONGODB_PREFIX}${SOURCE_MONGODB_TAG} ${LOCAL_TUTOR_DATA_DIRECTORY}mongodb/backup
sudo chown -R systemd-coredump ${LOCAL_TUTOR_DATA_DIRECTORY}mongodb/backup
sudo chgrp -R systemd-coredump ${LOCAL_TUTOR_DATA_DIRECTORY}mongodb/backup

# restore from your MongoDB backup.
# NOTE: "Error: Command failed with status 137: docker-compose" means that your EC2 instance is under-sized and ran out of memory
# during the restore operation.
tutor local exec mongodb bash
    # purge any existing data
    mongo                   # this does not require a username nor password
    use edxapp;
    db.dropDatabase();
    use openedx;
    db.dropDatabase();
    exit                    # you can disregard any console error messages from mongo
                            # about saving client state.

    # restore from our source backup
    mongorestore -d openedx /data/db/backup/edxapp/
    exit

# common sense drive volume space management: we should purge the copy of the backup data that we staged.
sudo rm -r "${LOCAL_TUTOR_DATA_DIRECTORY}/mongodb/backup/"


# 10. Upgrades
# NOTE the following in my case:
# - the upgrade --from=koa step only partially worked. The Django db migrations worked, but the MongoDB upgrade broke.
# - --from=lilac seems to have picked up where the other left off.
# - --from=maple was benign. it didn't perform any additional operations.
# -----------------------------------------------------------------------------

pip install "tutor[full]==12.2.0"       # installs Lilac by default
tutor local upgrade --from=koa          # upgrades MongoDb to v4.0.25
tutor local quickstart                  # accept all default responses.
                                        # you're now running Lilac

pip install "tutor[full]==13.3.1"       # installs Maple by default
tutor local upgrade --from=lilac        # this step doesn't appear to do anything
tutor local quickstart                  # accept all default responses. this step does a LOT.
                                        # you're now running Maple docker.io/overhangio/openedx:13.3.1
                                        #
                                        # your course version should have upgraded to version 16.
                                        # verify by running this query: SELECT id, version FROM openedx.course_overviews_courseoverview;

pip install "tutor[full]==14.2.4"       # installs Nutmeg by default
tutor local upgrade --from=maple        # pulls and runs docker.io/overhangio/openedx:14.2.4
                                        # generates this exception:
                                        # MySQLdb._exceptions.OperationalError: (1054, "Unknown column 'course_overviews_courseoverview.entrance_exam_enabled' in 'field list'")
                                        # because the db migration course_overviews.0026_courseoverview_entrance_exam runs out of sequence.
tutor local quickstart                  # accept all default responses.
                                        # you're now running Nutmeg
                                        #
                                        # your course version should have upgraded to version 17.

# IMPORTANT: we need to run legacy database transformation operations to
#            backfill any data that is assumed to exist in Nutmeg
#
#            these operations modify MySQL as well as MongoDB data.
#
#            these might take several minutes, depending on the size
#            of your MySQL data.
tutor local run cms ./manage.py cms backfill_course_tabs
tutor local run cms ./manage.py cms simulate_publish


# 11. Verify your upgrade: connect to MySQL
#      all of your courses should now be version 17
#
#    +-----------------------------------------+---------+
#    | id                                      | version |
#    +-----------------------------------------+---------+
#    | course-v1:UBC+001+2021_T1               |      17 |
#    | course-v1:UBC+2021_sandbox2+2021        |      17 |
#    | course-v1:UBC+AWS102+2021_T1            |      17 |
#    | course-v1:UBC+AZ-900+2021_T1            |      17 |
#    | course-v1:UBC+Blockchain1.1x+2021       |      17 |
#    | course-v1:UBC+Blockchain1.2x+2021       |      17 |
#    | course-v1:UBC+CBR002+F22_Nov            |      17 |
#
# -----------------------------------------------------------------------------
LOCAL_TUTOR_MYSQL_ROOT_PASSWORD=$(tutor config printvalue MYSQL_ROOT_PASSWORD)
LOCAL_TUTOR_MYSQL_ROOT_USERNAME=$(tutor config printvalue MYSQL_ROOT_USERNAME)
echo "LOCAL_TUTOR_MYSQL_ROOT_PASSWORD=$LOCAL_TUTOR_MYSQL_ROOT_PASSWORD"
echo "LOCAL_TUTOR_MYSQL_ROOT_USERNAME=$LOCAL_TUTOR_MYSQL_ROOT_USERNAME"

docker exec -it tutor_local_mysql_1 bash -l
    LOCAL_TUTOR_MYSQL_ROOT_PASSWORD=ADD-YOUR-PASSWORD-HERE
    LOCAL_TUTOR_MYSQL_ROOT_USERNAME=ADD-YOUR-USERNAME-HERE
    mysql -u$LOCAL_TUTOR_MYSQL_ROOT_USERNAME -p$LOCAL_TUTOR_MYSQL_ROOT_PASSWORD
    use openedx;
    SELECT id, version FROM openedx.course_overviews_courseoverview;
    exit
    exit


# 12. Dump the Nutmeg Mysql data and save to AWS S3
# https://docs.tutor.overhang.io/tutorials/datamigration.html
# -----------------------------------------------------------------------------

tutor local exec \
    -e USERNAME="$(tutor config printvalue MYSQL_ROOT_USERNAME)" \
    -e PASSWORD="$(tutor config printvalue MYSQL_ROOT_PASSWORD)" \
    mysql sh -c 'mysqldump --databases openedx --user=$USERNAME --password=$PASSWORD > /var/lib/mysql/openedx.sql'

sudo mv ${LOCAL_TUTOR_DATA_DIRECTORY}mysql/openedx.sql /home/ubuntu/migration/upgraded/
sudo chown -R ubuntu /home/ubuntu/migration/upgraded/openedx.sql
sudo chgrp -R ubuntu /home/ubuntu/migration/upgraded/openedx.sql

aws s3 cp /home/ubuntu/migration/upgraded/openedx.sql s3://${SOURCE_AWS_S3_BACKUP_BUCKET}/upgraded/

# 13. Dump the Nutmeg MongoDB data and save to AWS S3
# -----------------------------------------------------------------------------
if [ -d "/home/ubuntu/migration/upgraded/mongodb/" ]; then
    sudo rm -r /home/ubuntu/migration/upgraded/mongodb/
    echo "pruned stale upgrade results from the Docker file system"
fi
tutor local exec mongodb mongodump --out=/data/db/dump.mongodb

sudo mv ${LOCAL_TUTOR_DATA_DIRECTORY}mongodb/dump.mongodb /home/ubuntu/migration/upgraded/mongodb/
sudo chown -R ubuntu /home/ubuntu/migration/upgraded/mongodb
sudo chgrp -R ubuntu /home/ubuntu/migration/upgraded/mongodb

aws s3 cp /home/ubuntu/migration/upgraded/mongodb s3://${SOURCE_AWS_S3_BACKUP_BUCKET}/upgraded/mongodb/ --recursive


# 14. Import the transformed MongoDB data to the new Nutmeg platform
# -----------------------------------------------------------------------------
$(ksecret.sh mongodb-openedx $TARGET_KUBERNETES_OPENEDX_NAMESPACE)
mongorestore --drop --db=$MONGODB_DATABASE --host=$MONGODB_HOST --port=$MONGODB_PORT /home/ubuntu/migration/upgraded/mongodb/openedx

# 15. Import the transformed MySQL data to the new Nutmeg platform
# -----------------------------------------------------------------------------
$(ksecret.sh mysql-root $TARGET_KUBERNETES_SERVICE_NAMESPACE)
$(ksecret.sh mysql-openedx $TARGET_KUBERNETES_OPENEDX_NAMESPACE)

# step 1: import to the target server as db name 'openedx'
mysql -h $MYSQL_HOST -u $LOCAL_TUTOR_MYSQL_ROOT_USERNAME -p$LOCAL_TUTOR_MYSQL_ROOT_PASSWORD < /home/ubuntu/migration/upgraded/openedx.sql

# step 2: export and re-import the db with the correct target name $OPENEDX_MYSQL_DATABASE
#         note that in this step we will also fix the database collation
mysql -h $MYSQL_HOST -u $LOCAL_TUTOR_MYSQL_ROOT_USERNAME -p$LOCAL_TUTOR_MYSQL_ROOT_PASSWORD -e "DROP DATABASE IF EXISTS ${OPENEDX_MYSQL_DATABASE}; CREATE DATABASE ${OPENEDX_MYSQL_DATABASE} CHARACTER SET utf8 COLLATE utf8_general_ci"
mysqldump --set-gtid-purged=OFF --column-statistics=0 -h $MYSQL_HOST -u $LOCAL_TUTOR_MYSQL_ROOT_USERNAME -p$LOCAL_TUTOR_MYSQL_ROOT_PASSWORD openedx | mysql -h $MYSQL_HOST  -u $LOCAL_TUTOR_MYSQL_ROOT_USERNAME -p$LOCAL_TUTOR_MYSQL_ROOT_PASSWORD -D ${OPENEDX_MYSQL_DATABASE}
mysql -h $MYSQL_HOST -u $LOCAL_TUTOR_MYSQL_ROOT_USERNAME -p$LOCAL_TUTOR_MYSQL_ROOT_PASSWORD -e "DROP DATABASE IF EXISTS openedx"

# 16. Wrap up.
#     Best practice is to re-deploy your new enviroment after completing this data migration
#     operation. However, you can also do these last steps manually if necessary
#     - ensure that your admin account for the new platform exists and that the password is correct
#     - ensure that your admin account has an auth_userprofile record
#     - ensure that all Django migrations are applied
#
# ------------------------------------------------------

# 1.) Ensure that you're still able to connect to your target open edx plaform
# using your new admin credentials. These were overwritten by this database migration
# and so it's likely that the admin account was either deleted or that the password no
# longer matches what it was prior to running this database migration.
ksecret.sh admin-edx $TARGET_KUBERNETES_OPENEDX_NAMESPACE

# run this from the lms pod of your Kubernetes cluster
./manage.py lms createsuperuser --username 'admin' --email 'admin@exl.ubc.ca'

# 2.) ensure that the admin user account has a profile record. Depending on whether and how
# you restored your admin account credentials, a common oversight/bug is that the user profile
# record is missing, which will cause the following Python exception when you attempt to login
# to the lms or studio:
#
#   django.contrib.auth.models.User.profile.RelatedObjectDoesNotExist: User has no profile.
#
mysql -h $MYSQL_HOST -u $LOCAL_TUTOR_MYSQL_ROOT_USERNAME -p$LOCAL_TUTOR_MYSQL_ROOT_PASSWORD -e "INSERT INTO ${OPENEDX_MYSQL_DATABASE}.auth_userprofile (user_id, name, meta, courseware, language, location) select id as user_id, 'admin' as name, '{"session_id": null}' as meta, 'course.xml' as courseware, '' as language, '' as location from ${OPENEDX_MYSQL_DATABASE}.auth_user where username='admin';"


# 3.) check django shell to ensure that all migrations have been applied.
# if the openedx container that you're running in Kubernetes was built with a
# newer release of edx-platform then there might exist pending django migrations
# that you'll need to manually apply using manage.py in an lms/cms pod in your
# Kubernetes cluster.
#
# if this is the case then you'll see a message like the following each time
# you run manage.py:
#
#       You have 3 unapplied migration(s). Your project may not work properly until you apply the migrations for app(s): openedx_plugin, openedx_plugin_api.
#       Run 'python manage.py migrate' to apply them.
#
./manage.py lms migrate
./manage.py cms migrate
