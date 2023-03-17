#!/bin/bash
#---------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:       aug-2022
#
# usage: MongoDB installation tasks on Bastion.
#--------------------------------------------------------

# initialize local variables from Terraform template tags
PRIVATE_KEY_PEM=${ssh_private_key_filename}
PRIVATE_IPV4=${private_ip}

# remove any raw template files that might have gotten copied into
# the scripts folder by Terraform bulk copy operations.
rm /home/ubuntu/scripts/*.sh.tpl

# for diagnostics: dump the tmp contents. These files were
# added by provisioner directives in aws_instance in main.tf
ls /tmp/cookiecutter/mongodb/ -lha

# set aws-mandated permissions on the mongodb private key
echo setting permission on ~/.ssh/$PRIVATE_KEY_PEM
chmod 400 ~/.ssh/$PRIVATE_KEY_PEM

# add the private ip address of this instance to the bastion .ssh/known_hosts
echo "appending fingerprint to known_hosts"
ssh-keyscan $PRIVATE_IPV4 >> $HOME/.ssh/known_hosts

echo copying files from bastion tmp folder to $PRIVATE_IPV4

# prep mongodb config files, then copy to the mongodb instance
chmod +x /tmp/cookiecutter/mongodb/scripts/*.sh
echo copying scripts to home folder on $PRIVATE_IPV4
scp -i ~/.ssh/$PRIVATE_KEY_PEM -r /tmp/cookiecutter/mongodb/scripts/ ubuntu@$PRIVATE_IPV4:/home/ubuntu/
echo copying aws cli config to home folder on $PRIVATE_IPV4
scp -i ~/.ssh/$PRIVATE_KEY_PEM -r /tmp/cookiecutter/mongodb/.aws/ ubuntu@$PRIVATE_IPV4:/home/ubuntu/

# configure the login banner, copy login banner files from bastion tmp folder to the mongodb tmp folder
chmod 755 /tmp/cookiecutter/mongodb/etc/*
echo copying login banner files to mongodb tmp folder on $PRIVATE_IPV4
scp -i ~/.ssh/$PRIVATE_KEY_PEM -r /tmp/cookiecutter/mongodb/etc/ ubuntu@$PRIVATE_IPV4:/tmp/

# copy banner files from mongodb tmp folder to /etc/update-motd.d/
echo installing login banners on $PRIVATE_IPV4
ssh ubuntu@$PRIVATE_IPV4 -i ~/.ssh/$PRIVATE_KEY_PEM sudo cp /tmp/etc/09-welcome-banner /etc/update-motd.d/09-welcome-banner
ssh ubuntu@$PRIVATE_IPV4 -i ~/.ssh/$PRIVATE_KEY_PEM sudo cp /tmp/etc/10-help-text /etc/update-motd.d/10-help-text
# copy mongo.conf from mongodb tmp folder to /etc/mongo.conf
echo installing mongo.conf on $PRIVATE_IPV4
ssh ubuntu@$PRIVATE_IPV4 -i ~/.ssh/$PRIVATE_KEY_PEM sudo cp /tmp/etc/mongod.conf /etc/mongod.conf


# disable some of the original Ubuntu login banner components by removing the executable permission
echo setting permissions in $PRIVATE_IPV4:/etc/update-motd.d/
ssh ubuntu@$PRIVATE_IPV4 -i ~/.ssh/$PRIVATE_KEY_PEM sudo chmod 755 /etc/update-motd.d/*
ssh ubuntu@$PRIVATE_IPV4 -i ~/.ssh/$PRIVATE_KEY_PEM sudo chmod 644 /etc/update-motd.d/50-landscape-sysinfo
ssh ubuntu@$PRIVATE_IPV4 -i ~/.ssh/$PRIVATE_KEY_PEM sudo chmod 644 /etc/update-motd.d/85-fwupd
ssh ubuntu@$PRIVATE_IPV4 -i ~/.ssh/$PRIVATE_KEY_PEM sudo chmod 644 /etc/update-motd.d/88-esm-announce

# cleanup
# FIX NOTE: un-comment me
# "rm -rf /tmp/cookiecutter/mongodb",

# create an ssh shortcut inside the bastion .ssh folder for the mongodb instance
# FIX NOTE: I DO NOT WORK :(
#"grep -qxF 'Host mongodb' ~/.ssh/config || cat /tmp/cookiecutter/mongodb/ssh_config >> ~/.ssh/config && echo added ssh key and config to bastion.",

echo configuring .ssh/config on bastion
rm -f ~/.ssh/config
cat <<EOL >> ~/.ssh/config ${ssh_config}EOL

echo done!
