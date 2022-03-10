Tutor Open edX Production Devops Tools
======================================
.. image:: https://img.shields.io/badge/hack.d-Lawrence%20McDaniel-orange.svg
  :target: https://lawrencemcdaniel.com
  :alt: Hack.d Lawrence McDaniel

.. image:: https://img.shields.io/static/v1?logo=discourse&label=Forums&style=flat-square&color=ff0080&message=discuss.overhang.io
  :alt: Forums
  :target: https://discuss.overhang.io

.. image:: https://img.shields.io/static/v1?logo=readthedocs&label=Documentation&style=flat-square&color=blue&message=docs.tutor.overhang.io
  :alt: Documentation
  :target: https://docs.tutor.overhang.io
|
.. image:: https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white
  :target: https://www.terraform.io/
  :alt: Terraform

.. image:: https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white
  :target: https://aws.amazon.com/
  :alt: AWS

.. image:: https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white
  :target: https://www.docker.com/
  :alt: Docker

.. image:: https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white
  :target: https://kubernetes.io/
  :alt: Kubernetes
|

.. image:: https://avatars.githubusercontent.com/u/40179672
  :target: https://openedx.org/
  :alt: OPEN edX
  :width: 75px
  :align: center

.. image:: https://overhang.io/static/img/tutor-logo.svg
  :target: https://docs.tutor.overhang.io/
  :alt: Tutor logo
  :width: 75px
  :align: center

|


This repository contains Terraform code and Github Actions workflows to deploy and manage a `Tutor <https://docs.tutor.overhang.io/>`_ Kubernetes-managed
production installation of Open edX that will automatically scale up, reliably supporting several hundred thousand learners.


The Terraform scripts in this repo provide a 1-click means of creating / updating / destroying the following for each environment:

- LMS at https://{{ cookiecutter.prod_environment }}.{{ cookiecutter.global_root_domain }}
- CMS at https://studio.{{ cookiecutter.prod_environment }}.{{ cookiecutter.global_root_domain }}
- CDN at https://cdn.{{ cookiecutter.prod_environment }}.{{ cookiecutter.global_root_domain }} linked to a public read-only S3 bucket named {{ cookiecutter.prod_environment }}-{{ cookiecutter.global_platform_name }}-{{ cookiecutter.global_platform_region }}-storage
- public ssh access via a t2.micro Ubuntu 20.04 LTS bastion EC2 instance at bastion.{{ cookiecutter.prod_environment }}.{{ cookiecutter.global_root_domain }}
- daily data backups archived into a private S3 bucket named {{ cookiecutter.prod_environment }}-{{ cookiecutter.global_platform_name }}-{{ cookiecutter.global_platform_region }}-mongodb-backup

You can also optionally automatically create additional environments for say, dev and test and QA and so forth. 
These would result in environments like the following:

- LMS at https://dev.{{ cookiecutter.prod_environment }}.{{ cookiecutter.global_root_domain }}
- CMS at https://studio.dev.{{ cookiecutter.prod_environment }}-{{ cookiecutter.global_root_domain }}
- CDN at https://cdn.dev.{{ cookiecutter.prod_environment }}.{{ cookiecutter.global_root_domain }} linked to an S3 bucket named dev-{{ cookiecutter.global_platform_name }}-{{ cookiecutter.global_platform_region }}-storage
- daily data backups archived into an S3 bucket named dev-{{ cookiecutter.global_platform_name }}-{{ cookiecutter.global_platform_region }}-mongodb-backup


Important Considerations
------------------------

- this code only works for AWS.
- the root domain {{ cookiecutter.global_root_domain }} must be hosted in `AWS Route53 <https://console.aws.amazon.com/route53/v2/hostedzones#>`_
- resources are deployed to this AWS region: ``{{ cookiecutter.global_aws_region }}``
- the Github Actions workflows depend on secrets `located here <settings> (see 'secrets/actions' from the left menu bar) `_
- the Github Actions use an AWS IAM key pair from `this manually-created user named *ci* <https://console.aws.amazon.com/iam/home#/users/ci?section=security_credentials>`_
- the collection of resources created by these scripts **will generate AWS costs of around $0.41 USD per hour ($10.00 USD per day)** while the platform is in a mostly-idle pre-production state. This cost will grow proportionally to your production work loads. You can view your `AWS Billing dashboard here <https://console.aws.amazon.com/billing/home?region={{ cookiecutter.global_aws_region }}#/>`_
- **BE ADVISED** that `MySQL RDS <https://{{ cookiecutter.global_aws_region }}.console.aws.amazon.com/rds/home?region={{ cookiecutter.global_aws_region }}#databases:>`_, `MongoDB <https://{{ cookiecutter.global_aws_region }}.console.aws.amazon.com/docdb/home?region={{ cookiecutter.global_aws_region }}#subnetGroups>`_ and `Redis ElastiCache <https://{{ cookiecutter.global_aws_region }}.console.aws.amazon.com/elasticache/home?region={{ cookiecutter.global_aws_region }}#redis:>`_ are vertically scaled **manually** and therefore require some insight and potential adjustments on your part. All of these services are defaulted to their minimum instance sizes which you can modify in the `environment configuration file <terraform/environments/prod/env.hcl>`_

Quick Start
-----------

I. Add Your Secret Credentials To This Repository
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Github Actions workflows in this repository depend on several `workflow secrets <settings>`_ including two sets of AWS IAM keypairs, one for CI workflows and another for the AWS Simple Email Service. 
Additionally, they require a Github Personal Access Token (PAT) for a Github user account with all requisite privileges in this repository as well as any other repositories that are cloned during any of the build / installation pipelines.

.. image:: doc/repository-secrets.png
  :width: 700
  :alt: Github Repository Secrets

II. Configure Your Open edX Back End
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Set your `global parameters <terraform/environments/global.hcl>`_

.. code-block:: hcl

  locals {
    platform_name    = "{{ cookiecutter.global_platform_name }}"
    platform_region  = "{{ cookiecutter.global_platform_region }}"
    root_domain      = "{{ cookiecutter.global_root_domain }}.ai"
    aws_region       = "{{ cookiecutter.global_aws_region }}"
    account_id       = "{{ cookiecutter.global_account_id }}"
    ec2_ssh_key_name = "{{ cookiecutter.global_ec2_ssh_key_name }}"
  }


Set your `production environment parameters <terraform/environments/prod/env.hcl>`_

.. code-block:: hcl

  locals {

  environment           = "{{ cookiecutter.prod_environment }}"
  subdomains            = ["dev", "test"]
  environment_domain    = "${local.environment}.${local.global_vars.locals.root_domain}"
  environment_namespace = "${local.environment}-${local.global_vars.locals.platform_name}-${local.global_vars.locals.platform_region}"


  # AWS infrastructure sizing
                                    # 2 vCPU 4gb
  mongodb_instance_class          = "db.t3.medium"
  mongodb_cluster_size            = 1

                                    # 1 vCPU 2gb
  mysql_instance_class            = "db.t2.small"

                                    # 1 vCPU 1.55gb
  redis_node_type                 = "cache.t2.small"

                                    # 2 vCPU 8gb
  eks_worker_group_instance_type  = "t3.large" 

  }



III. Build Your Open edX Backend
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The backend build procedure is automated using `Terragrunt <https://terragrunt.gruntwork.io/>`_ for `Terraform <https://www.terraform.io/>`_. 
Installation instructions are avilable at both of these web sites. 

Terraform scripts rely on the `AWS CLI (Command Line Interface) Tools <https://aws.amazon.com/cli/>`_. Installation instructions for Windows, macOS and Linux are available on this site. 
We also recommend that you install `k9s <https://k9scli.io/>`_, a popular tool for adminstering a Kubernetes cluster.

.. code-block:: shell

  # -------------------------------------
  # to manage an individual resource
  # -------------------------------------
  cd ./terraform/environments/prod/mongodb
  terragrunt init
  terragrunt plan
  terragrunt apply
  terragrunt destroy

  # -------------------------------------
  # to build the entire backend
  # -------------------------------------

  # 1. create the VPC
  cd ./terraform/environments/prod/vpc
  terragrunt apply

  # 2. create the Elastic Kubernetes Cluster
  cd ../eks
  terragrunt apply

  # 3. create everthing else
  cd ..
  terragrunt run-all apply


IV. Connect To Your backend Services
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Terraform creates friendly subdomain names for any of the backend services which you are likely to connect: Cloudfront, MySQL, Mongo and Redis.
Passwords for the root/admin accounts are accessible from Kubernetes Secrets. Note that each of MySQL, MongoDB and Redis reside in private subnets. These services can only be accessed on the command line from the Bastion.

.. code-block:: shell

  ssh bastion.{{ cookiecutter.prod_environment }}.{{ cookiecutter.global_root_domain }} -i path/to/{{ cookiecutter.global_ec2_ssh_key_name }}.pem

  mysql -h mysql.{{ cookiecutter.prod_environment }}.{{ cookiecutter.global_root_domain }} -u root -p

  mongo --port 27017 --host mongo.master.{{ cookiecutter.prod_environment }}.{{ cookiecutter.global_root_domain }} -u root -p
  mongo --port 27017 --host mongo.reader.{{ cookiecutter.prod_environment }}.{{ cookiecutter.global_root_domain }} -u root -p

  redis-cli -h redis.primary.{{ cookiecutter.prod_environment }}.{{ cookiecutter.global_root_domain }} -p 6379

Specifically with regard to MySQL, several 3rd party analytics tools provide out-of-the-box connectivity to MySQL via a bastion server. Following is an example of how to connect to your MySQL environment using MySQL Workbench.

.. image:: doc/mysql-workbench.png
  :width: 700
  :alt: Connecting to MySQL Workbench


Continuous Integration (CI)
---------------------------

Both the Build as well as the Deploy workflows were pre-configured based on your responses to the CookieCutter questionnaire. Look for these two files in `.github/workflows <.github/workflows>`_.
 You'll find additional Open edX deployment and configuration files in `ci/tutor-build <ci/tutor-build>`_ and `ci/tutor-deploy <ci/tutor-deploy>`_


I. Build your Tutor Docker Image
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use `this automated Github Actions workflow <actions/workflows/tutor_build_image.yml>`_ to build a customized Open edX Docker container based on the latest stable version of Open edX (current maple.2) and
your Open edX custom theme repository and Open edX plugin repository. Your new Docker image will be automatically uploaded to `AWS Amazon Elastic Container Registry <https://{{ cookiecutter.global_aws_region }}.console.aws.amazon.com/ecr/repositories?region={{ cookiecutter.global_aws_region }}>`_
 

II. Deploy your Docker Image to a Kubernetes Cluster
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use `this automated Github Actions workflow <actions/workflows/tutor_deploy_prod.yml>`_ to deploy your customized Docker container to a Kubernetes Cluster.
Open edX LMS and Studio configuration parameters are located `here <ci/tutor-deploy/environments/prod/settings_merge.json>`_.


About The Open edX Platform Back End
------------------------------------

The scripts in the `terraform <terraform>`_ folder provide 1-click functionality to create and manage all resources in your AWS account. 
These scripts generally follow current best practices for implementing a large Python Django web platform like Open edX in a secure, cloud-hosted environment.
Besides reducing human error, there are other tangible improvements to managing your cloud infrastructure with Terraform as opposed to creating and managing your cloud infrastructure resources manually from the AWS console. 
For example, all AWS resources are systematically tagged which in turn facilitates use of CloudWatch and improved consolidated logging and AWS billing expense reporting.

These scripts will create the following resources in your AWS account:

- **MySQL**. uses `AWS RDS <https://aws.amazon.com/rds/>`_ for all MySQL data, accessible inside the vpc as mysql.{{ cookiecutter.prod_environment }}.{{ cookiecutter.global_root_domain }}:3306. Instance size settings are located in the `environment configuration file <terraform/environments/prod/env.hcl>`_, and other common configuration settings `are located here <terraform/environments/prod/rds/terragrunt.hcl>`_. Passwords are stored in `Kubernetes Secrets <https://kubernetes.io/docs/concepts/configuration/secret/>`_ accessible from the EKS cluster.
- **MongoDB**. uses `AWS DocumentDB <https://aws.amazon.com/documentdb/>`_ for all MongoDB data, accessible insid the vpc as mongodb.master.{{ cookiecutter.prod_environment }}.{{ cookiecutter.global_root_domain }}:27017 and mongodb.reader.{{ cookiecutter.prod_environment }}.{{ cookiecutter.global_root_domain }}. Instance size settings are located in the `environment configuration file <terraform/environments/prod/env.hcl>`_, and other common configuration settings `are located here <terraform/components/documentdb>`_. Passwords are stored in `Kubernetes Secrets <https://kubernetes.io/docs/concepts/configuration/secret/>`_ accessible from the EKS cluster.
- **Redis**. uses `AWS ElastiCache <https://aws.amazon.com/elasticache/>`_ for all Django application caches, accessible inside the vpc as cache.{{ cookiecutter.prod_environment }}.{{ cookiecutter.global_root_domain }}. Instance size settings are located in the `environment configuration file <terraform/environments/prod/env.hcl>`_. This is necessary in order to make the Open edX application layer completely ephemeral. Most importantly, user's login session tokens are persisted in Redis and so these need to be accessible to all app containers from a single Redis cache. Common configuration settings `are located here <terraform/environments/prod/redis/terragrunt.hcl>`_. Passwords are stored in `Kubernetes Secrets <https://kubernetes.io/docs/concepts/configuration/secret/>`_ accessible from the EKS cluster.
- **Container Management**. uses this `automated Github Actions workflow <.github/workflows/tutor_build_image.yml>`_ to build your `tutor Open edX container <https://docs.tutor.overhang.io/>`_ and then register it in `Amazon Elastic Container Registry (Amazon ECR) <https://aws.amazon.com/ecr/>`_. Uses this `automated Github Actions workflow <.github/workflows/tutor_deploy_prod.yml>`_ to deploy your container to `AWS Amazon Elastic Kubernetes Service (EKS) <https://aws.amazon.com/eks/>`_. EKS worker instance size settings are located in the `environment configuration file <terraform/environments/prod/env.hcl>`_. Note that tutor provides out-of-the-box support for Kubernetes. Terraform leverages Elastic Kubernetes Service to create a Kubernetes cluster onto which all services are deployed. Common configuration settings `are located here <terraform/environments/prod/eks/terragrunt.hcl>`_
- **User Data**. uses `AWS S3 <https://aws.amazon.com/s3/>`_ for storage of user data. This installation makes use of a `Tutor plugin to offload object storage <https://github.com/hastexo/tutor-contrib-s3>`_ from the Ubuntu file system to AWS S3. It creates a public read-only bucket named of the form {{ cookiecutter.prod_environment }}-{{ cookiecutter.global_platform_name }}-{{ cookiecutter.global_platform_region }}-storage, with write access provided to edxapp so that app-generated static content like user profile images, xblock-generated file content, application badges, e-commerce pdf receipts, instructor grades downloads and so on will be saved to this bucket. This is not only a necessary step for making your application layer ephemeral but it also facilitates the implementation of a CDN (which Terraform implements for you). Terraform additionally implements a completely separate, more secure S3 bucket for archiving your daily data backups of MySQL and MongoDB. Common configuration settings `are located here <terraform/environments/prod/s3/terragrunt.hcl>`_
- **CDN**. uses `AWS Cloudfront <https://aws.amazon.com/cloudfront/>`_ as a CDN, publicly acccessible as https://cdn.{{ cookiecutter.prod_environment }}.{{ cookiecutter.global_root_domain }}. Terraform creates Cloudfront distributions for each of your enviornments. These are linked to the respective public-facing S3 Bucket for each environment, and the requisite SSL/TLS ACM-issued certificate is linked. Terraform also automatically creates all Route53 DNS records of form cdn.{{ cookiecutter.prod_environment }}.{{ cookiecutter.global_root_domain }}. Common configuration settings `are located here <terraform/environments/prod/cloudfront/terragrunt.hcl>`_
- **Password & Secrets Management** uses `Kubernetes Secrets <https://kubernetes.io/docs/concepts/configuration/secret/>`_ in the EKS cluster. Open edX software relies on many passwords and keys, collectively referred to in this documentation simply as, "*secrets*". For all back services, including all Open edX applications, system account and root passwords are randomly and strongluy generated during automated deployment and then archived in EKS' secrets repository. This methodology facilitates routine updates to all of your passwords and other secrets, which is good practice these days. Common configuration settings `are located here <terraform/environments/prod/secrets/terragrunt.hcl>`_
- **SSL Certs**. Uses `AWS Certificate Manager <https://aws.amazon.com/certificate-manager/>`_ and LetsEncrypt. Terraform creates all SSL/TLS certificates. It uses a combination of AWS Certificate Manager (ACM) as well as LetsEncrypt. Additionally, the ACM certificates are stored in two locations: your aws-region as well as in us-east-1 (as is required by AWS CloudFront). Common configuration settings `are located here <terraform/components/eks/acm.tf>`_
- **DNS Management** uses `AWS Route53 <https://aws.amazon.com/route53/>`_ hosted zones for DNS management. Terraform expects to find your root domain already present in Route53 as a hosted zone. It will automatically create additional hosted zones, one per environment for production, dev, test and so on. It automatically adds NS records to your root domain hosted zone as necessary to link the zones together. Configuration data exists within several components but the highest-level settings `are located here <terraform/components/eks/route53.tf>`_
- **System Access** uses `AWS Identity and Access Management (IAM) <https://aws.amazon.com/iam/>`_ to manage all system users and roles. Terraform will create several user accounts with custom roles, one or more per service.
- **Network Design**. uses `Amazon Virtual Private Cloud (Amazon VPC) <https://aws.amazon.com/vpc/>`_ based on the AWS account number provided in the `global configuration file <terraform/environments/global.hcl>`_ to take a top-down approach to compartmentalize all cloud resources and to customize the operating enviroment for your Open edX resources. Terraform will create a new virtual private cloud into which all resource will be provisioned. It creates a sensible arrangment of private and public subnets, network security settings and security groups. See additional VPC documentation  `here <terraform/environments/prod/vpc>`_
- **Proxy Access to Backend Services**. uses an `Amazon EC2 <https://aws.amazon.com/ec2/>`_ t2.micro Ubuntu instance publicly accessible via ssh as bastion.{{ cookiecutter.prod_environment }}.{{ cookiecutter.global_root_domain }}:22 using the ssh key specified in the `global configuration file <terraform/environments/global.hcl>`_.  For security as well as performance reasons all backend services like MySQL, Mongo, Redis and the Kubernetes cluster are deployed into their own private subnets, meaning that none of these are publicly accessible. See additional Bastion documentation  `here <terraform/environments/prod/bastion>`_. Terraform creates a t2.micro EC2 instance to which you can connect via ssh. In turn you can connect to services like MySQL via the bastion. Common configuration settings `are located here <terraform/environments/prod/bastion/terragrunt.hcl>`_. Note that if you are cost conscious then you could alternatively use `AWS Cloud9 <https://aws.amazon.com/cloud9/>`_ to gain access to all backend services.

FAQ
---

Why Use Tutor?
~~~~~~~~~~~~~~
Tutor is the official Docker-based Open edX distribution, both for production and local development. The goal of Tutor is to make it easy to deploy, customize, upgrade and scale Open edX. Tutor is reliable, fast, extensible, and it is already used to deploy hundreds of Open edX platforms around the world.

- Runs on Docker
- 1-click installation and upgrades
- Comes with batteries included: theming, SCORM, HTTPS, web-based administration interface, mobile app, custom translations…
- Extensible architecture with plugins
- Works out of the box with Kubernetes
- Amazing premium plugins available in the Tutor Wizard Edition, including Cairn the next-generation analytics solution for Open edX.


Why Use Docker?
~~~~~~~~~~~~~~~
In a word, `Docker <https://docs.docker.com/get-started/>`_ is about "Packaging" your software in a way that simplifies how it is installed and managed so that you benefit from fast, consistent delivery of your applications.
A Docker container image is a lightweight, standalone, executable package of software that includes everything needed to run an application: code, runtime, system tools, system libraries and settings. Meanwhile, Docker is an open platform for developing, shipping, and running applications.

For context, any software which you traditionally relied on Linux package managers like apt, snap or yum can alternativley be installed and run as a Docker container. 
Some examples of stuff which an Open edX platform depends: Nginx, MySQL, MongoDB, Redis, and the Open edX application software itself which Tutor bundles into a container using `Docker Compose <https://en.wikipedia.org/wiki/Infrastructure_as_code>`_.

Why Use Kubernetes?
~~~~~~~~~~~~~~~~~~
`Kubernetes <https://kubernetes.io/>`_ manages Docker containers in a deployment enviornment. It provides an easy way to scale your application, and is a superior, cost-effective alternative to you manually creating and maintaing individual virtual servers for each of your backend services.
It keeps code operational and speeds up the delivery process. Kubernetes enables automating a lot of resource management and provisioning tasks.

Your Open edX platform runs via multiple Docker containers: the LMS Django application , CMS Django application, one or more Celery-based worker nodes for each of these applications, nginx, Caddy, and any backend services that tutor manages like Nginx and SMTP for example. 
Kubernetes creates EC2 instances and then decides where to place each of these containers based on various real-time resource-based factors. 
This leads to your EC2 instances carrying optimal workloads, all the time. 
Behind the scenes Kubernetes (EKS in our case) uses an EC2 Elastic Load Balancer (ELB) with an auto-scaling policy, both of which you can see from the AWS EC2 dashboard.


Why Use Terraform?
~~~~~~~~~~~~~~~~~~

`Terraform <https://www.terraform.io/>`_ allows you to manage the entire lifecycle of your AWS cloud infrastructure using `infrastructure as code (IAC) <https://en.wikipedia.org/wiki/Infrastructure_as_code>`_. That means declaring infrastructure components in configuration files that are then used by Terraform to provision, adjust and tear down your AWS cloud infrastructure. There are tangential benefits to using IAC.

1. **Maintain all of your backend configuration data in a single location**. This allows you to take a more holistic, top-down approach to planning and managing your backend resources, which leads to more reliable service for your users.
2. **Leverage git**. This is a big deal! Managing your backend as IAC means you can track individual changes to your configuration over time. More importantly, it means you can reverse backend configuration changes that didn't go as planned.
3. **It's top-down and bottom-up**. You can start at the network design level and work your way up the stack, taking into consideration factors like security, performance and cost.
4. **More thorough**. You see every possible configuration setting for each cloud service. This in turns helps to you to consider all aspects of your configuration decisions.
5. **More secure**. IAC leads to recurring reviews of software versions and things getting patched when they should. It compels you to regularly think about the ages of your passwords. It makes it easier for you to understand how network concepts like subnets, private networks, CIDRs and port settings are being used across your entire backend.
6. **Saves money**. Taking a top-down approach with IAC will lead to you proactively and sensibly sizing your infrastructure, so that you don't waste money on infrastructure that you don't use.
7. **It's what the big guys use**. Your Open edX backend contains a lot of complexity, and it provides a view into the far-larger worlds of platforms like Google, Facebook, Tiktok and others. Quite simply, technology stacks have evolved to a point where we no longer have the ability to artesanlly manage any one part. That in a nutshell is why major internet platforms have been so quick to adopt tools like Terraform.

Why Use Terragrunt?
~~~~~~~~~~~~~~~~~~~

`Terragrunt <https://terragrunt.gruntwork.io/>`_ is a thin wrapper that provides extra tools for keeping your configurations DRY, working with multiple Terraform modules, and managing remote state. DRY means don't repeat yourself. That helped a lot with self-repeating modules we had to use in this architecture.