# PLACEHOLDER FOR TUTOR CRIB NOTES

## tutor customizations

https://docs.tutor.overhang.io/configuration.html

add the following to the $(tutor config printroot)/config.yml:
OPENEDX_EXTRA_PIP_REQUIREMENTS:
- "git+https://github.com/StepwiseMath/stepwise-edx-plugin.git"
- "git+https://github.com/StepwiseMath/tutor-contrib-stepwise-config.git"


git clone https://github.com/StepwiseMath/stepwise-edx-theme.git \
  "$(tutor config printroot)/env/build/openedx/themes/stepwise-edx-theme"

tutor images build openedx


## I. import MySQL data

```bash
MYSQL_ROOT_PASSWORD=$(tutor config printvalue MYSQL_ROOT_PASSWORD)
MYSQL_ROOT_USERNAME=root

docker exec -i tutor_local_mysql_1 sh -c 'exec mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "DROP DATABASE openedx;"'
docker exec -i tutor_local_mysql_1 sh -c 'exec mysql -uroot -p$MYSQL_ROOT_PASSWORD' < /home/ubuntu/backups/mysql/mysql-data-koa.sql # EDIT THIS
```

## II. import MongoDB data

```bash
sudo mkdir /home/ubuntu/.local/share/tutor/data/mongodb/backup
sudo mv /home/ubuntu/backups/mongodb/mongo-dump-koa/edxapp /home/ubuntu/.local/share/tutor/data/mongodb/backup/. # EDIT THIS
sudo chown -R systemd-coredump /home/ubuntu/.local/share/tutor/data/mongodb/backup
sudo chgrp -R systemd-coredump /home/ubuntu/.local/share/tutor/data/mongodb/backup

tutor local exec mongodb bash
mongorestore -d openedx /data/db/backup/edxapp/
sudo rm -r /home/ubuntu/.local/share/tutor/data/mongodb/backup
```

## III. upgrades

```bash
tutor local upgrade --from=nutmeg
tutor local quickstart
```

## IV. ad hoc Mysql shell

```bash
MYSQL_ROOT_PASSWORD=$(tutor config printvalue MYSQL_ROOT_PASSWORD)
MYSQL_ROOT_USERNAME=root

docker exec -it tutor_local_mysql_1 bash -l
MYSQL_ROOT_PASSWORD=ADD-YOUR-PASSWORD-HERE
MYSQL_ROOT_USERNAME=root
mysql -u$MYSQL_ROOT_USERNAME -p$MYSQL_ROOT_PASSWORD
use openedx;
```

## V. dump Mysql data

```bash
tutor local exec \
    -e USERNAME="$(tutor config printvalue MYSQL_ROOT_USERNAME)" \
    -e PASSWORD="$(tutor config printvalue MYSQL_ROOT_PASSWORD)" \
    mysql sh -c 'mysqldump --databases openedx --user=$USERNAME --password=$PASSWORD > /var/lib/mysql/dump.sql'

sudo mv /home/ubuntu/.local/share/tutor/data/mysql/dump.sql ~/backups/mysql/
sudo chown -R ubuntu ~/backups/mysql/dump.sql
sudo chgrp -R ubuntu ~/backups/mysql/dump.sql
tar -czf ~/backups/mysql/dump.tgz  ~/backups/mysql/dump.sql
aws s3 cp ~/backups/mysql/dump.sql s3://academiacentral-global-staging-backup/
```

## VI. dump MongoDB data

```bash
tutor local exec mongodb mongodump --out=/data/db/dump.mongodb
sudo mv /home/ubuntu/.local/share/tutor/data/mongodb/dump.mongodb ~/backups/mongodb/
sudo chown -R ubuntu ~/backups/mongodb/dump.mongodb
sudo chgrp -R ubuntu ~/backups/mongodb/dump.mongodb
aws s3 cp ~/backups/mongodb/ s3://academiacentral-global-staging-backup/ --recursive
```

## VII. Development environment

- https://docs.tutor.overhang.io/dev.html
- https://discuss.openedx.org/t/open-edx-devstack-development-with-apple-macbook-m1-silicon-arm-architecture/5051/10
- https://github.com/kdmccormick/tutor-contrib-kdmccormick/blob/master/tutorkdmccormick/automountvenvs.py
