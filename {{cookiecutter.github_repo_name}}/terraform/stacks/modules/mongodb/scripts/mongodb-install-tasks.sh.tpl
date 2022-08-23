#!/bin/bash
#---------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:       aug-2022
#
# usage: MongoDB installation tasks on Bastion.
#--------------------------------------------------------

rm /home/ubuntu/scripts/*.sh.tpl
ls /tmp/openedx_devops/mongodb/ -lha

# set aws-mandated permissions on the mongodb private key
echo "setting permission on ~/.ssh/${ssh_private_key_filename}"
chmod 400 ~/.ssh/${ssh_private_key_filename}

# add the private ip address of this instance to the bastion .ssh/known_hosts
echo "appending fingerprint to known_hosts"
ssh-keyscan ${private_ip} >> $HOME/.ssh/known_hosts

echo "copying files from bastion tmp folder to ${private_ip}"

# prep mongodb config files, then copy to the mongodb instance
chmod +x /tmp/openedx_devops/mongodb/scripts/*.sh
echo copying scripts to home folder on ${private_ip}
scp -i ~/.ssh/${ssh_private_key_filename} -r /tmp/openedx_devops/mongodb/scripts/ ubuntu@${private_ip}:/home/ubuntu/
echo copying aws cli config to home folder on ${private_ip}
scp -i ~/.ssh/${ssh_private_key_filename} -r /tmp/openedx_devops/mongodb/.aws/ ubuntu@${private_ip}:/home/ubuntu/

# configure the login banner, copy login banner files from bastion tmp folder to the mongodb tmp folder
chmod 755 /tmp/openedx_devops/mongodb/etc/*
echo copying login banner files to mongodb tmp folder on ${private_ip}
scp -i ~/.ssh/${ssh_private_key_filename} -r /tmp/openedx_devops/mongodb/etc/ ubuntu@${private_ip}:/tmp/

# copy banner files from mongodb tmp folder to /etc/update-motd.d/
echo installing login banners on ${private_ip}
ssh ubuntu@${private_ip} -i ~/.ssh/${ssh_private_key_filename} sudo cp /tmp/etc/09-welcome-banner /etc/update-motd.d/09-welcome-banner
ssh ubuntu@${private_ip} -i ~/.ssh/${ssh_private_key_filename} sudo cp /tmp/etc/10-help-text /etc/update-motd.d/10-help-text

# disable some of the original Ubuntu login banner components by removing the executable permission
echo setting permissions in ${private_ip}:/etc/update-motd.d/
ssh ubuntu@${private_ip} -i ~/.ssh/${ssh_private_key_filename} sudo chmod 755 /etc/update-motd.d/*
ssh ubuntu@${private_ip} -i ~/.ssh/${ssh_private_key_filename} sudo chmod 644 /etc/update-motd.d/50-landscape-sysinfo
ssh ubuntu@${private_ip} -i ~/.ssh/${ssh_private_key_filename} sudo chmod 644 /etc/update-motd.d/85-fwupd
ssh ubuntu@${private_ip} -i ~/.ssh/${ssh_private_key_filename} sudo chmod 644 /etc/update-motd.d/88-esm-announce

# cleanup
# FIX NOTE: un-comment me
# "rm -rf /tmp/openedx_devops/mongodb",

# create an ssh shortcut inside the bastion .ssh folder for the mongodb instance
# FIX NOTE: I DO NOT WORK :(
#"grep -qxF 'Host mongodb' ~/.ssh/config || cat /tmp/openedx_devops/mongodb/ssh_config >> ~/.ssh/config && echo added ssh key and config to bastion.",

echo configuring .ssh/config on bastion
rm -f ~/.ssh/config
cat <<EOL >> ~/.ssh/config ${ssh_config}EOL
echo done!
