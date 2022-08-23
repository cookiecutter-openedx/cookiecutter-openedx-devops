#!/bin/bash
#---------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:       june-2022
#
# usage: called once by Terraform during first apply.
#        mostly used as a workaround to permissions problems
#        in cases where we need to use sudo.
#--------------------------------------------------------


if [ -d "/tmp/openedx_devops/etc" ]
then
    sudo cp /tmp/openedx_devops/etc/09-welcome-banner /etc/update-motd.d/09-welcome-banner
    sudo chmod 755 /etc/update-motd.d/09-welcome-banner

    sudo cp /tmp/openedx_devops/etc/10-help-text /etc/update-motd.d/10-help-text
    sudo chmod 755 /etc/update-motd.d/10-help-text

    # set execute permissions for only the banner components
    # we want to display at login.
    sudo chmod 755 /etc/update-motd.d/*
    sudo chmod 644 /etc/update-motd.d/50-landscape-sysinfo
    sudo chmod 644 /etc/update-motd.d/85-fwupd
    sudo chmod 644 /etc/update-motd.d/88-esm-announce

    echo "added openedx_devops login banner"
fi

# setup a .kube/config file w correct permissions
mkdir -p .kube
touch .kube/config
chmod 600 .kube/config
