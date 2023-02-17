# Automated Data Backup Documentation

The Cookiecutter automatically generates and configures several resources that bear on data backups, remote storage, and data retention policies. Backups are managed from the bastion server, bastion.{{ cookiecutter.global_services_subdomain }}.{{ cookiecutter.global_root_domain }}, and are scheduled and executed using cron. The cron job itself is automatically generated for you. It runs as the ubuntu user and can be viewed and edited using the command ```crontab -e``` from the command line.

See Bash source code: [install-tasks.sh](../terraform/stacks/modules/ec2_bastion/scripts/install-tasks.sh)

## Setup

### Software

You will need to run ~/scripts/install.sh from the Bastion to install and automatically configure software that the backup scripts require. The script is mostly automated and uses a combination of 'apt get' and Homebrew to install packages.

See Bash source code: [install.sh](../terraform/stacks/modules/ec2_bastion/scripts/install.sh.tpl)

### Credentials

#### AW CLI

Terraform automatically creates an IAM key-secret with admin permissions, and installs these credentials on the Bastion server. After running ~/scripts/install.sh the aws cli should work as expected.

See Terraform source code: [main.tf](../terraform/stacks/modules/ec2_bastion/main.tf)

#### Kubernetes

The backup script retrieves MySQL and MongoDB connection credentials from Kubernetes secrets via kubectl. You will need to manually add the bastion's IAM user to Kubernete's aws-auth configMap. See the main README section, "VII. Add more Kubernetes admins" for instructions.

## Backup scripts

The backup scripts are written in bash and are located on the Bastion server in the folder ~/scripts. There are separate scripts for MySQL and MongoDB, and both are preconfigured and ready to use.

MySQL script source: [openedx-backup-mysql.sh](../terraform/stacks/modules/ec2_bastion/scripts/openedx-backup-mysql.sh)
MongoDB script source: [openedx-backup-mongodb.sh](../terraform/stacks/modules/ec2_bastion/scripts/openedx-backup-mongodb.sh)

## Remote storage

Terraform creates a dedicated AWS S3 bucket, {{ cookiecutter.environment_name }}-{{ cookiecutter.global_platform_name }}-{{ cookiecutter.global_platform_region }}-backup.s3.amazonaws.com, for archiving backups. This bucket does not provide public access. Note that it is preconfigured with a lifecycle policy to retain large files (greater than 1Gb) for 30 days.

See Terraform source code: [openedx_backups.tf](../terraform/environments/modules/s3_openedx_storage/openedx_backups.tf)

## Local storage

Backups are stored locally as date-stamped tarball archives on the Bastion server in ~/backups.
The retention policy setting is located in each respective backup script file for MySQL and MongoDB, located in ~/scripts/.

## Log files

Each of the backup scripts generate log output that is saved to the home folder.
