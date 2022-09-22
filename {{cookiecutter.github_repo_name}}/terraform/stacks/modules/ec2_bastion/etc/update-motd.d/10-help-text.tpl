#!/bin/sh
#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:       aug-2022
#
# usage:      print the login help menu for openedx_devops cookiecutter.
#------------------------------------------------------------------------------

printf " Installed Applications\n"
printf "   Docker ce:               $(docker --version) \n"
printf "   aws-cli:                 $(aws --version) \n"
printf "   Python:                  $(python3 --version) \n"
printf "   pip:                     $(pip3 --version) \n"
printf "   tutor:                   $(tutor --version | cut -f3 -d' ') \n"
printf "   k9s:                     $(k9s version) \n"
printf " \n"
printf " Quickstart:\n"
printf "   run install.sh to install preconfigured software packages\n"
printf "   run kconfig.sh ${stack_namespace} ${aws_region} to configure .kube access for k9s\n"
printf " \n"
printf " Help: \n"
printf "   aws                       preconfigured AWS command-line interface \n"
printf "   aws-ec2-spot-prices.sh    view pricing for AWS EC2 Spot instances \n"
printf "   aws-route53-dns.sh        query DNS record entries from AWS Route53 \n"
printf "   helm_update.sh            update the local helm charts repo \n"
printf "   install.sh                install preconfigured software packages \n"
printf "   openedx-install-venv.sh   install edx-platform and all requirements for prod and dev \n"
printf "   openedx-backup-mongodb.sh dump the MongoDB databases to the Ubuntu file system \n"
printf "   openedx-backup-mysql.sh   dump the MySQL databases to the Ubuntu file system \n"
printf "   update.sh                 update all preconfigured software packages \n"
printf " \n"
printf " Kubernetes\n"
printf "   k9s                       launch the Kubernetes admin console:  \n"
printf "   kconfig.sh                configure kubectl:  \n"
printf "   klog.sh                   download a k8s pod log file \n"
printf "   ksecret.sh                echo a k8s secret to the console \n"
printf "   kubectl                   preconfigured Kubernets command-line interface\n"
printf " \n"
printf " MySQL\n"
printf "   root credentials:         ksecret.sh mysql-root ${stack_namespace} \n"
printf "   client connection:        mysql -h mysql.${root_domain} -u root -p "your-password" \n"
printf " \n"
printf " MongoDB\n"
printf "   server connection:        ssh mongodb \n"
printf "   client connection:        mongo 'mongodb://mongodb.${root_domain}:27017' \n"
printf " \n"
printf " tutor\n"
printf "   tutor                     run tutor on the command line \n"
printf "   tutor-developer-build.sh  builds a local development environment \n"
printf "   tutor-reset.sh            completely reinitialize your local Tutor environment \n"
printf " \n"
