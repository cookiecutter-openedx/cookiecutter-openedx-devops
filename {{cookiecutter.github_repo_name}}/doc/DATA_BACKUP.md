# Automated Data Backup Documentation

The Cookiecutter automatically generates and configures several resources that bear on data backups, remote storage, and data retention policies. Backups are managed from the bastion server and are scheduled and executed using cron. The cron job itself is automatically generated for you. It runs as the ubuntu user and can be viewed and edited using the command 'crontab -e' from the command line.

## Setup

### Software

You will need to run ~/scripts/install.sh from the Bastion to install and automatically configure software that the backup scripts require. The script is mostly automated and uses a combination of 'apt get' and Homebrew to install packages.

### Credentials

#### AW CLI

Terraform automatically creates an IAM key-secret with admin permissions, and installs these credentials on the Bastion server. After running ~/scripts/install.sh the aws cli should work as expected.

#### Kubernetes

The backup script retrieves MySQL and MongoDB connection credentials from Kubernetes secrets via kubectl. You will need to manually add the bastion's IAM user to Kubernete's aws-auth configMap. See the main README section, "VII. Add more Kubernetes admins" for instructions.

## Backup scripts

The backup scripts are written in bash and are located on the Bastion server in the folder ~/scripts. There are separate scripts for MySQL and MongoDB, and both are preconfigured and ready to use.

## Remote storage

Terraform creates a dedicated AWS S3 bucket for archiving backups. This bucket does not provide public access. Note that it is preconfigured with a lifecycle policy to retain large files (greater than 1Gb) for 30 days.

## Local storage

Backups are stored locally as date-stamped tarball archives on the Bastion server in ~/backups.
The retention policy setting is located in each respective backup script file for MySQL and MongoDB, located in ~/scripts/.

## Log files

Each of the backup scripts generate log output that is saved to the home folder.
