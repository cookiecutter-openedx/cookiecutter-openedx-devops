Tutor Open edX Production Devops Tools
======================================
.. image:: https://img.shields.io/badge/hack.d-Lawrence%20McDaniel-orange.svg
  :target: https://lawrencemcdaniel.com
  :alt: Hack.d Lawrence McDaniel

.. image:: https://img.shields.io/static/v1?logo=discourse&label=Forums&style=flat-square&color=ff0080&message=discuss.openedx.org
  :alt: Forums
  :target: https://discuss.openedx.org/

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

Open edX Application Software Endpoints
---------------------------------------

- LMS: https://{{ cookiecutter.environment_subdomain }}.{{ cookiecutter.global_root_domain }}
- Course Management Studio: https://{{ cookiecutter.environment_studio_subdomain }}.{{ cookiecutter.environment_subdomain }}.{{ cookiecutter.global_root_domain }}
{% if cookiecutter.wordpress_add_site|upper == "Y" -%}
- Wordpress: https://{{ cookiecutter.wordpress_subdomain }}.{{ cookiecutter.global_root_domain }}. WordPress is a free and open-source content management system written in php and paired with a MySQL database with supported HTTPS. Features include a plugin architecture and a template system, referred to within WordPress as "Themes"
{% endif -%}

Additional AWS Resources
~~~~~~~~~~~~~~~~~~~~~~~~

- **Remote Data Backup**: {{ cookiecutter.environment_name }}-{{ cookiecutter.global_platform_name }}-{{ cookiecutter.global_platform_region }}-backup.s3.amazonaws.com
- **Open edX Application User Storage**: {{ cookiecutter.environment_name }}-{{ cookiecutter.global_platform_name }}-{{ cookiecutter.global_platform_region }}-storage.s3.amazonaws.com
- **Content Delivery Network (CDN)**: https://cdn.{{ cookiecutter.environment_subdomain }}.{{ cookiecutter.global_root_domain }} linked to a public read-only S3 bucket named {{ cookiecutter.environment_subdomain }}-{{ cookiecutter.global_platform_name }}-{{ cookiecutter.global_platform_region }}-storage

Backend Services Endpoints
--------------------------

- **Bastion**: bastion.{{ cookiecutter.global_services_subdomain }}.{{ cookiecutter.global_root_domain }}:22. Public ssh access to a {{ cookiecutter.bastion_instance_type }} Ubuntu 20.04 LTS bastion EC2 instance that's preconfigure with all of the software that you'll need to adminster this stack.
- **MySQL**: mysql.{{ cookiecutter.global_services_subdomain }}.{{ cookiecutter.global_root_domain }}:3306. Private VPC access to your AWS RDS MySQL {{ cookiecutter.mysql_instance_class }} instance with allocated storage of {{ cookiecutter.mysql_allocated_storage }}.
- **MongoDB**: mongodb.{{ cookiecutter.global_services_subdomain }}.{{ cookiecutter.global_root_domain }}:27017. Private VPC access to your EC2-based installation of MongoDB on a {{ cookiecutter.mongodb_instance_type }} instance with allocated storage of {{ cookiecutter.mongodb_allocated_storage }}.
{% if cookiecutter.stack_add_k8s_dashboard|upper == "Y" -%}
- **Kubernetes Dashboard**: Dashboard is a web-based Kubernetes user interface. You can use Dashboard to deploy containerized applications to a Kubernetes cluster, troubleshoot your containerized application, and manage the cluster resources. You can use Dashboard to get an overview of applications running on your cluster, as well as for creating or modifying individual Kubernetes resources (such as Deployments, Jobs, DaemonSets, etc). For example, you can scale a Deployment, initiate a rolling update, restart a pod or deploy new applications using a deploy wizard. See: `Kubernetes Dashboard Quickstart <./doc/KUBERNETES_DASHBOARD.md>`_
{% endif -%}
{% if cookiecutter.stack_add_k8s_kubeapps|upper == "Y" -%}
- **Kubeapps**: https://kubeapps.{{ cookiecutter.global_services_subdomain }}.{{ cookiecutter.global_root_domain }}. Kubeapps is an in-cluster web-based application that enables users with a one-time installation to deploy, manage, and upgrade applications on a Kubernetes cluster
{% endif -%}
{% if cookiecutter.stack_add_k8s_kubecost|upper == "Y" -%}
- **Kubecost**: https://kubecost.{{ cookiecutter.global_services_subdomain }}.{{ cookiecutter.global_root_domain }}. Kubecost provides real-time cost visibility and insights for teams using Kubernetes, helping you continuously reduce your cloud costs.
{% endif -%}
{% if cookiecutter.stack_add_k8s_prometheus|upper == "Y" -%}
- **Grafana**: https://grafana.{{ cookiecutter.global_services_subdomain }}.{{ cookiecutter.global_root_domain }}. Grafana is a multi-platform open source analytics and interactive visualization web application. It provides charts, graphs, and alerts for the web when connected to supported data sources.
{% endif -%}

You can also optionally automatically create additional environments for say, dev and test and QA and so forth.
These would result in environments like the following:

- LMS at https://dev.{{ cookiecutter.environment_subdomain }}.{{ cookiecutter.global_root_domain }}
- CMS at https://{{ cookiecutter.environment_studio_subdomain }}.dev.{{ cookiecutter.environment_subdomain }}-{{ cookiecutter.global_root_domain }}
- CDN at https://cdn.dev.{{ cookiecutter.environment_subdomain }}.{{ cookiecutter.global_root_domain }} linked to an S3 bucket named dev-{{ cookiecutter.global_platform_name }}-{{ cookiecutter.global_platform_region }}-storage
- daily data backups archived into an S3 bucket named dev-{{ cookiecutter.global_platform_name }}-{{ cookiecutter.global_platform_region }}-mongodb-backup

Administration
--------------

- `System Administration Overview <./doc/SYSTEM_ADMINISTRATION.md>`_
- `Passwords, Credentials and Sensitive Data Management <./doc/SECRETS_MANAGEMENT.md>`_
- `Remote Data Backup & Restore <./doc/DATA_BACKUP.md>`_
- `Updating This Repository <./doc/UPGRADES.md>`_

Quick Start
-----------

See: `Getting Started Guide <./doc/QUICKSTART.rst>`_


Important Considerations
------------------------

- this code only works for AWS.
- the root domain {{ cookiecutter.global_root_domain }} must be hosted in `AWS Route53 <https://console.aws.amazon.com/route53/v2/hostedzones#>`_. Terraform will create several DNS entries inside of this hosted zone, and it will optionally create additional hosted zones (one for each additional optional environment) that will be linked to the hosted zone of your root domain.
- resources are deployed to this AWS region: ``{{ cookiecutter.global_aws_region }}``
- the Github Actions workflows depend on secrets `located here <settings> (see 'secrets/actions' from the left menu bar) `_
- the Github Actions use an AWS IAM key pair from `this manually-created user named *ci* <https://console.aws.amazon.com/iam/home#/users/ci?section=security_credentials>`_
- the collection of resources created by these scripts **will generate AWS costs of around $0.41 USD per hour ($10.00 USD per day)** while the platform is in a mostly-idle pre-production state. This cost will grow proportionally to your production work loads. You can view your `AWS Billing dashboard here <https://console.aws.amazon.com/billing/home?region={{ cookiecutter.global_aws_region }}#/>`_
- **BE ADVISED** that `MySQL RDS <https://{{ cookiecutter.global_aws_region }}.console.aws.amazon.com/rds/home?region={{ cookiecutter.global_aws_region }}#databases:>`_, `MongoDB <https://{{ cookiecutter.global_aws_region }}.console.aws.amazon.com/docdb/home?region={{ cookiecutter.global_aws_region }}#subnetGroups>`_ and `Redis ElastiCache <https://{{ cookiecutter.global_aws_region }}.console.aws.amazon.com/elasticache/home?region={{ cookiecutter.global_aws_region }}#redis:>`_ are vertically scaled **manually** and therefore require some insight and potential adjustments on your part. All of these services are defaulted to their minimum instance sizes which you can modify in the `environment configuration file <terraform/environments/{{ cookiecutter.environment_name }}/env.hcl>`_

About The Open edX Platform Back End
------------------------------------

The scripts in the `terraform <terraform>`_ folder provide 1-click functionality to create and manage all resources in your AWS account.
These scripts generally follow current best practices for implementing a large Python Django web platform like Open edX in a secure, cloud-hosted environment.
Besides reducing human error, there are other tangible improvements to managing your cloud infrastructure with Terraform as opposed to creating and managing your cloud infrastructure resources manually from the AWS console.
For example, all AWS resources are systematically tagged which in turn facilitates use of CloudWatch and improved consolidated logging and AWS billing expense reporting.

These scripts will create the following resources in your AWS account:

- **Compute Cluster**. uses `AWS EC2 <https://aws.amazon.com/ec2/>`_ behind a Classic Load Balancer.
- **Kubernetes**. Uses `AWS Elastic Kubernetes Service `_ to implement a Kubernetes cluster onto which all applications and scheduled jobs are deployed as pods.
- **MySQL**. uses `AWS RDS <https://aws.amazon.com/rds/>`_ for all MySQL data, accessible inside the vpc as mysql.{{ cookiecutter.environment_subdomain }}.{{ cookiecutter.global_root_domain }}:3306. Instance size settings are located in the `environment configuration file <terraform/environments/{{ cookiecutter.environment_name }}/env.hcl>`_, and other common configuration settings `are located here <terraform/environments/{{ cookiecutter.environment_name }}/rds/terragrunt.hcl>`_. Passwords are stored in `Kubernetes Secrets <https://kubernetes.io/docs/concepts/configuration/secret/>`_ accessible from the EKS cluster.
- **MongoDB**. uses `AWS DocumentDB <https://aws.amazon.com/documentdb/>`_ for all MongoDB data, accessible insid the vpc as mongodb.master.{{ cookiecutter.environment_subdomain }}.{{ cookiecutter.global_root_domain }}:27017 and mongodb.reader.{{ cookiecutter.environment_subdomain }}.{{ cookiecutter.global_root_domain }}. Instance size settings are located in the `environment configuration file <terraform/environments/{{ cookiecutter.environment_name }}/env.hcl>`_, and other common configuration settings `are located here <terraform/modules/documentdb>`_. Passwords are stored in `Kubernetes Secrets <https://kubernetes.io/docs/concepts/configuration/secret/>`_ accessible from the EKS cluster.
- **Redis**. uses `AWS ElastiCache <https://aws.amazon.com/elasticache/>`_ for all Django application caches, accessible inside the vpc as cache.{{ cookiecutter.environment_subdomain }}.{{ cookiecutter.global_root_domain }}. Instance size settings are located in the `environment configuration file <terraform/environments/{{ cookiecutter.environment_name }}/env.hcl>`_. This is necessary in order to make the Open edX application layer completely ephemeral. Most importantly, user's login session tokens are persisted in Redis and so these need to be accessible to all app containers from a single Redis cache. Common configuration settings `are located here <terraform/environments/{{ cookiecutter.environment_name }}/redis/terragrunt.hcl>`_. Passwords are stored in `Kubernetes Secrets <https://kubernetes.io/docs/concepts/configuration/secret/>`_ accessible from the EKS cluster.
- **Container Registry**. uses this `automated Github Actions workflow <.github/workflows/tutor_build_image.yml>`_ to build your `tutor Open edX container <https://docs.tutor.overhang.io/>`_ and then register it in `Amazon Elastic Container Registry (Amazon ECR) <https://aws.amazon.com/ecr/>`_. Uses this `automated Github Actions workflow <.github/workflows/tutor_deploy_prod.yml>`_ to deploy your container to `AWS Amazon Elastic Kubernetes Service (EKS) <https://aws.amazon.com/kubernetes/>`_. EKS worker instance size settings are located in the `environment configuration file <terraform/environments/{{ cookiecutter.environment_name }}/env.hcl>`_. Note that tutor provides out-of-the-box support for Kubernetes. Terraform leverages Elastic Kubernetes Service to create a Kubernetes cluster onto which all services are deployed. Common configuration settings `are located here <terraform/environments/{{ cookiecutter.environment_name }}/kubernetes/terragrunt.hcl>`_
- **User Data**. uses `AWS S3 <https://aws.amazon.com/s3/>`_ for storage of user data. This installation makes use of a `Tutor plugin to offload object storage <https://github.com/hastexo/tutor-contrib-s3>`_ from the Ubuntu file system to AWS S3. It creates a public read-only bucket named of the form {{ cookiecutter.environment_name }}-{{ cookiecutter.global_platform_name }}-{{ cookiecutter.global_platform_region }}-storage, with write access provided to edxapp so that app-generated static content like user profile images, xblock-generated file content, application badges, e-commerce pdf receipts, instructor grades downloads and so on will be saved to this bucket. This is not only a necessary step for making your application layer ephemeral but it also facilitates the implementation of a CDN (which Terraform implements for you). Terraform additionally implements a completely separate, more secure S3 bucket for archiving your daily data backups of MySQL and MongoDB. Common configuration settings `are located here <terraform/environments/{{ cookiecutter.environment_name }}/s3/terragrunt.hcl>`_
- **CDN**. uses `AWS Cloudfront <https://aws.amazon.com/cloudfront/>`_ as a CDN, publicly acccessible as https://cdn.{{ cookiecutter.environment_subdomain }}.{{ cookiecutter.global_root_domain }}. Terraform creates Cloudfront distributions for each of your enviornments. These are linked to the respective public-facing S3 Bucket for each environment, and the requisite SSL/TLS ACM-issued certificate is linked. Terraform also automatically creates all Route53 DNS records of form cdn.{{ cookiecutter.environment_subdomain }}.{{ cookiecutter.global_root_domain }}. Common configuration settings `are located here <terraform/environments/{{ cookiecutter.environment_name }}/cloudfront/terragrunt.hcl>`_
- **Password & Secrets Management** uses `Kubernetes Secrets <https://kubernetes.io/docs/concepts/configuration/secret/>`_ in the EKS cluster. Open edX software relies on many passwords and keys, collectively referred to in this documentation simply as, "*secrets*". For all back services, including all Open edX applications, system account and root passwords are randomly and strongluy generated during automated deployment and then archived in EKS' secrets repository. This methodology facilitates routine updates to all of your passwords and other secrets, which is good practice these days. Common configuration settings `are located here <terraform/environments/{{ cookiecutter.environment_name }}/secrets/terragrunt.hcl>`_
- **SSL Certs**. Uses `AWS Certificate Manager <https://aws.amazon.com/certificate-manager/>`_ and LetsEncrypt. Terraform creates all SSL/TLS certificates. It uses a combination of AWS Certificate Manager (ACM) as well as LetsEncrypt. Additionally, the ACM certificates are stored in two locations: your aws-region as well as in us-east-1 (as is required by AWS CloudFront). Common configuration settings `are located here <terraform/modules/kubernetes/acm.tf>`_
- **DNS Management** uses `AWS Route53 <https://aws.amazon.com/route53/>`_ hosted zones for DNS management. Terraform expects to find your root domain already present in Route53 as a hosted zone. It will automatically create additional hosted zones, one per environment for production, dev, test and so on. It automatically adds NS records to your root domain hosted zone as necessary to link the zones together. Configuration data exists within several modules but the highest-level settings `are located here <terraform/modules/kubernetes/route53.tf>`_
- **System Access** uses `AWS Identity and Access Management (IAM) <https://aws.amazon.com/iam/>`_ to manage all system users and roles. Terraform will create several user accounts with custom roles, one or more per service.
- **Network Design**. uses `Amazon Virtual Private Cloud (Amazon VPC) <https://aws.amazon.com/vpc/>`_ based on the AWS account number provided in the `global configuration file <terraform/environments/global.hcl>`_ to take a top-down approach to compartmentalize all cloud resources and to customize the operating enviroment for your Open edX resources. Terraform will create a new virtual private cloud into which all resource will be provisioned. It creates a sensible arrangment of private and public subnets, network security settings and security groups. See additional VPC documentation  `here <terraform/environments/{{ cookiecutter.environment_name }}/vpc>`_
- **Proxy Access to Backend Services**. uses an `Amazon EC2 <https://aws.amazon.com/ec2/>`_ t2.micro Ubuntu instance publicly accessible via ssh as bastion.{{ cookiecutter.environment_subdomain }}.{{ cookiecutter.global_root_domain }}:22 using the ssh key specified in the `global configuration file <terraform/environments/global.hcl>`_.  For security as well as performance reasons all backend services like MySQL, Mongo, Redis and the Kubernetes cluster are deployed into their own private subnets, meaning that none of these are publicly accessible. See additional Bastion documentation  `here <terraform/environments/{{ cookiecutter.environment_name }}/bastion>`_. Terraform creates a t2.micro EC2 instance to which you can connect via ssh. In turn you can connect to services like MySQL via the bastion. Common configuration settings `are located here <terraform/environments/{{ cookiecutter.environment_name }}/bastion/terragrunt.hcl>`_. Note that if you are cost conscious then you could alternatively use `AWS Cloud9 <https://aws.amazon.com/cloud9/>`_ to gain access to all backend services.

Cookiecutter Manifest
---------------------

This repository was generated using `Cookiecutter <https://cookiecutter.readthedocs.io/>`_. Keep your repository up to date with the latest Terraform code and configuration versions of the Open edX application stack, AWS infrastructure services and api code libraries by occasionally re-generating the Cookiecutter template using this `make file <./make.sh>`_.

.. list-table:: Cookiecutter Version Control
  :widths: 75 20
  :header-rows: 1

  * - Software
    - Version
  * - `Open edX Named Release <https://edx.readthedocs.io/projects/edx-developer-docs/en/latest/named_releases.html>`_
    - {{ cookiecutter.ci_openedx_release_tag }}
  * - `MySQL Server <https://www.mysql.com/>`_
    - {{ cookiecutter.mysql_engine_version }}
  * - `Redis Cache <https://redis.io/>`_
    - {{ cookiecutter.redis_engine_version }}
  * - `Tutor Docker-based Open edX Installer <https://docs.tutor.overhang.io/>`_
    - {{ cookiecutter.ci_build_tutor_version }}
  * - `Tutor Plugin: Object storage for Open edX with S3 <https://github.com/hastexo/tutor-contrib-s3>`_
    - {{ cookiecutter.ci_openedx_actions_tutor_plugin_enable_s3_version }}
  {% if cookiecutter.ci_deploy_install_backup_plugin|upper == "Y" -%}
  * - `Tutor Plugin: Backup & Restore <https://github.com/hastexo/tutor-contrib-backup>`_
    - {{ cookiecutter.ci_openedx_actions_tutor_plugin_build_backup_version }}
  {% endif -%}
  {% if cookiecutter.ci_deploy_install_credentials_server|upper == "Y" -%}
  * - `Tutor Plugin: Credentials Application <https://github.com/lpm0073/tutor-contrib-credentials>`_
    - {{ cookiecutter.ci_openedx_actions_tutor_plugin_enable_credentials_version }}
  {% endif -%}
  * - `Tutor Plugin: Discovery Service <https://github.com/overhangio/tutor-discovery>`_
    - latest stable
  * - `Tutor Plugin: Micro Front-end Service <https://github.com/overhangio/tutor-mfe>`_
    - latest stable
  {% if cookiecutter.ci_deploy_install_ecommerce_service|upper == "Y" -%}
  * - `Tutor Plugin: Ecommerce Service <https://github.com/overhangio/tutor-ecommerce>`_
    - latest stable
  {% endif -%}
  {% if cookiecutter.ci_deploy_install_xqueue_service|upper == "Y" -%}
  * - `Tutor Plugin: Xqueue Service <https://github.com/overhangio/tutor-xqueue>`_
    - latest stable
  {% endif -%}
  {% if cookiecutter.ci_deploy_install_notes_service|upper == "Y" -%}
  * - `Tutor Plugin: Notes Service <https://github.com/overhangio/tutor-notes>`_
    - latest stable
  {% endif -%}
  {% if cookiecutter.ci_deploy_install_forum_service|upper == "Y" -%}
  * - `Tutor Plugin: Discussion Forum Service <https://github.com/overhangio/tutor-forum>`_
    - latest stable
  {% endif -%}
  * - `Tutor Plugin: Android Application <https://github.com/overhangio/tutor-android>`_
    - latest stable
  * - `Kubernetes Cluster <https://kubernetes.io/>`_
    - {{ cookiecutter.kubernetes_cluster_version }}
  * - `Terraform <https://www.terraform.io/>`_
    - {{ cookiecutter.terraform_required_version }}
  * - Terraform Provider `Kubernetes <https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs>`_
    - {{ cookiecutter.terraform_provider_kubernetes_version }}
  * - Terraform Provider `kubectl <https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs>`_
    - {{ cookiecutter.terraform_provider_hashicorp_kubectl_version }}
  * - Terraform Provider `helm <https://registry.terraform.io/providers/hashicorp/helm/latest/docs>`_
    - {{ cookiecutter.terraform_provider_hashicorp_helm_version }}
  * - Terraform Provider `AWS <https://registry.terraform.io/providers/hashicorp/aws/latest/docs>`_
    - {{ cookiecutter.terraform_provider_hashicorp_aws_version }}
  * - Terraform Provider `Local <https://registry.terraform.io/providers/hashicorp/local/latest/docs>`_
    - {{ cookiecutter.terraform_provider_hashicorp_local_version }}
  * - Terraform Provider `Random <https://registry.terraform.io/providers/hashicorp/random/latest/docs>`_
    - {{ cookiecutter.terraform_provider_hashicorp_random_version }}
  * - `terraform-aws-modules/acm <https://registry.terraform.io/modules/terraform-aws-modules/acm/aws/latest>`_
    - {{ cookiecutter.terraform_aws_modules_acm }}
  * - `terraform-aws-modules/cloudfront <https://registry.terraform.io/modules/terraform-aws-modules/cloudfront/aws/latest>`_
    - {{ cookiecutter.terraform_aws_modules_cloudfront }}
  * - `terraform-aws-modules/eks <https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest>`_
    - {{ cookiecutter.terraform_aws_modules_eks }}
  * - `terraform-aws-modules/iam <https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest>`_
    - {{ cookiecutter.terraform_aws_modules_iam }}
  * - `terraform-aws-modules/rds <https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/latest>`_
    - {{ cookiecutter.terraform_aws_modules_rds }}
  * - `terraform-aws-modules/s3-bucket <https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest>`_
    - {{ cookiecutter.terraform_aws_modules_s3 }}
  * - `terraform-aws-modules/security-group <https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest>`_
    - {{ cookiecutter.terraform_aws_modules_sg }}
  * - `terraform-aws-modules/vpc <https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest>`_
    - {{ cookiecutter.terraform_aws_modules_vpc }}
  * - `Helm cert-manager <https://charts.jetstack.io>`_
    - {{ cookiecutter.terraform_helm_cert_manager }}
  * - `Helm Ingress Nginx Controller <https://kubernetes.github.io/ingress-nginx/>`_
    - {{ cookiecutter.terraform_helm_ingress_nginx_controller }}
  * - `Helm Vertical Pod Autoscaler <https://github.com/cowboysysop/charts/tree/master/charts/vertical-pod-autoscaler>`_
    - {{ cookiecutter.terraform_helm_vertical_pod_autoscaler }}
  * - `Helm Kubernetes Dashboard <https://kubernetes.github.io/dashboard/>`_
    - {{ cookiecutter.terraform_helm_dashboard }}
  * - `Helm kubecost <https://kubecost.github.io/cost-analyzer/>`_
    - {{ cookiecutter.terraform_helm_kubecost }}
  * - `Helm kubeapps <https://bitnami.com/stack/kubeapps/helm>`_
    - {{ cookiecutter.terraform_helm_kubeapps }}
  * - `Helm Karpenter <https://artifacthub.io/packages/helm/karpenter/karpenter>`_
    - {{ cookiecutter.terraform_helm_karpenter }}
  * - `Helm Metrics Server <https://kubernetes-sigs.github.io/metrics-server/>`_
    - {{ cookiecutter.terraform_helm_metrics_server }}
  * - `Helm Prometheus <https://prometheus-community.github.io/helm-charts/>`_
    - {{ cookiecutter.terraform_helm_prometheus }}
  * - `Helm Wordpress <https://charts.bitnami.com/bitnami/wordpress>`_
    - {{ cookiecutter.wordpress_helm_chart_version }}
  * - `Helm phpMyAdmin <https://charts.bitnami.com/bitnami/phpmyadmin>`_
    - {{ cookiecutter.phpmyadmin_helm_chart_version }}
  * - `openedx-actions/tutor-k8s-init <https://github.com/marketplace/actions/open-edx-tutor-k8s-init>`_
    - {{ cookiecutter.ci_openedx_actions_tutor_k8s_init_version }}
  * - `openedx-actions/tutor-k8s-configure-edx-secret <https://github.com/openedx-actions/tutor-k8s-configure-edx-secret>`_
    - {{ cookiecutter.ci_openedx_actions_tutor_k8s_configure_edx_secret_version }}
  * - `openedx-actions/tutor-k8s-configure-edx-admin <https://github.com/openedx-actions/tutor-k8s-configure-edx-admin>`_
    - {{ cookiecutter.ci_openedx_actions_tutor_k8s_configure_edx_admin }}
  * - `openedx-actions/tutor-k8s-configure-jwt <https://github.com/openedx-actions/tutor-k8s-configure-jwt>`_
    - {{ cookiecutter.ci_openedx_actions_tutor_k8s_configure_jwt_version }}
  * - `openedx-actions/tutor-k8s-configure-mysql <https://github.com/openedx-actions/tutor-k8s-configure-mysql>`_
    - {{ cookiecutter.ci_openedx_actions_tutor_k8s_configure_mysql_version }}
  * - `openedx-actions/tutor-k8s-configure-mongodb <https://github.com/openedx-actions/tutor-k8s-configure-mongodb>`_
    - {{ cookiecutter.ci_openedx_actions_tutor_k8s_configure_mongodb_version }}
  * - `openedx-actions/tutor-k8s-configure-redis <https://github.com/openedx-actions/tutor-k8s-configure-redis>`_
    - {{ cookiecutter.ci_openedx_actions_tutor_k8s_configure_redis_version }}
  * - `openedx-actions/tutor-k8s-configure-smtp <https://github.com/openedx-actions/tutor-k8s-configure-smtp>`_
    - {{ cookiecutter.ci_openedx_actions_tutor_k8s_configure_smtp_version }}
  * - `openedx-actions/tutor-print-dump <https://github.com/openedx-actions/tutor-print-dump>`_
    - {{ cookiecutter.ci_openedx_actions_tutor_print_dump }}
  * - `openedx-actions/tutor-plugin-build-backup <https://github.com/openedx-actions/tutor-plugin-build-backup>`_
    - {{ cookiecutter.ci_openedx_actions_tutor_plugin_build_backup_version }}
  * - `openedx-actions/tutor-plugin-build-credentials <https://github.com/openedx-actions/tutor-plugin-build-credentials>`_
    - {{ cookiecutter.ci_openedx_actions_tutor_plugin_build_credentials_version }}
  * - `openedx-actions/tutor-plugin-build-license-manager <https://github.com/openedx-actions/tutor-plugin-build-license-manager>`_
    - {{ cookiecutter.ci_openedx_actions_tutor_plugin_build_license_manager_version }}
  * - `openedx-actions/tutor-plugin-build-openedx <https://github.com/openedx-actions/tutor-plugin-build-openedx>`_
    - {{ cookiecutter.ci_openedx_actions_tutor_plugin_build_openedx_version }}
  * - `openedx-actions/tutor-plugin-build-openedx-add-requirement <https://github.com/openedx-actions/tutor-plugin-build-openedx-add-requirement>`_
    - {{ cookiecutter.ci_openedx_actions_tutor_plugin_build_openedx_add_requirement_version }}
  * - `openedx-actions/tutor-plugin-build-openedx-add-theme <https://github.com/openedx-actions/tutor-plugin-build-openedx-add-theme>`_
    - {{ cookiecutter.ci_openedx_actions_tutor_plugin_build_openedx_add_theme_version }}
  * - `openedx-actions/tutor-plugin-enable-backup <https://github.com/openedx-actions/tutor-plugin-enable-backup>`_
    - {{ cookiecutter.ci_openedx_actions_tutor_plugin_enable_backup_version }}
  * - `openedx-actions/tutor-plugin-enable-credentials <https://github.com/openedx-actions/tutor-plugin-enable-credentials>`_
    - {{ cookiecutter.ci_openedx_actions_tutor_plugin_enable_credentials_version }}
  * - `openedx-actions/tutor-plugin-enable-discovery <https://github.com/openedx-actions/tutor-plugin-enable-discovery>`_
    - {{ cookiecutter.ci_openedx_actions_tutor_plugin_enable_discovery_version }}
  * - `openedx-actions/tutor-plugin-enable-ecommerce <https://github.com/openedx-actions/tutor-plugin-enable-ecommerce>`_
    - {{ cookiecutter.ci_openedx_actions_tutor_plugin_enable_ecommerce_version }}
  * - `openedx-actions/tutor-plugin-enable-forum <https://github.com/openedx-actions/tutor-plugin-enable-forum>`_
    - {{ cookiecutter.ci_openedx_actions_tutor_plugin_enable_forum_version }}
  * - `openedx-actions/tutor-plugin-enable-k8s-deploy-tasks <https://github.com/openedx-actions/tutor-plugin-enable-k8s-deploy-tasks>`_
    - {{ cookiecutter.ci_openedx_actions_tutor_plugin_enable_k8s_deploy_tasks_version }}
  * - `openedx-actions/tutor-enable-plugin-license-manager <https://github.com/openedx-actions/tutor-enable-plugin-license-manager>`_
    - {{ cookiecutter.ci_openedx_actions_tutor_plugin_enable_license_manager_version }}
  * - `openedx-actions/tutor-plugin-enable-notes <https://github.com/openedx-actions/tutor-plugin-enable-notes>`_
    - {{ cookiecutter.ci_openedx_actions_tutor_plugin_enable_notes_version }}
  * - `openedx-actions/tutor-plugin-enable-s3 <https://github.com/openedx-actions/tutor-plugin-enable-s3>`_
    - {{ cookiecutter.ci_openedx_actions_tutor_plugin_enable_s3_version }}
  * - `openedx-actions/tutor-plugin-enable-xqueue <https://github.com/openedx-actions/tutor-plugin-enable-xqueue>`_
    - {{ cookiecutter.ci_openedx_actions_tutor_plugin_enable_xqueue_version }}
