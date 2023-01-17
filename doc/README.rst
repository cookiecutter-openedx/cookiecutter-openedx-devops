Project Generation Options
==========================


Project Identifiers
-------------------

- **github_account_name:**
  The Github organization for the source cookiecutter (ie this repository).
  This is a command-line option only and is will not otherwise be sound in this
  sourcecode.

  *default value: lpm0073*

- **github_repo_name:**
  The Github repository for the source cookiecutter (ie this repository).
  This is a command-line option only and is will not otherwise be sound in this
  sourcecode.

  *default value: openedx_devops*

- **environment_name:**
  This cookiecutter will create one Open edX deployment environment for you,
  named environment_name and located in the file path ./terraform/environments/environment_name.
  You'll find extensive references to environment_name throughout ./terraform/environments/modules.
  Note that you can copy-paste this folder to create additional environments.

  *default value: prod*

- **environment_subdomain:**
  This cookiecutter will create several URL endpoints for each environment_name, with
  each endpoint residing inside a common subdomain named environment_subdomain.

  *default value: courses*

- **environment_studio_subdomain:**
  The subdomain name to use for the Open edX Course Management Studio URL endpoint.
  *default value: studio*

- **global_platform_name:**
  This is a global variable, stored in ./terraform/glocal.hcl that is ysed for creating
  the standardized naming identifiers in AWS resources and resource tags. You'll also
  find references to global_platform_name in the pre-configured helper bash scripts and the
  Kubernetes ingress manifests. global_platform_name is a short description identifying the Open edX platform that this
  cookiecutter will ultimately deploy, typically this is the root domain name for the project.

  *default value: yourschool*

- **global_platform_region:**
  This is a global variable, stored in ./terraform/glocal.hcl that is ysed for creating
  the standardized naming identifiers in AWS resources and resource tags. You'll also
  find references to global_platform_name in the pre-configured helper bash scripts and the
  Kubernetes ingress manifests. global_platform_region is a short description identifying the
  geographic area that this Open edX installation will serve. This value is nearly always set
  to the value 'global', meaning that this is the sole platform and it serves a global audience.

  *default value: global*

- **global_platform_shared_resource_identifier:**
  This is a stack variable, stored in ./terraform/stacks/global_platform_shared_resource_identifier/stack.hcl that is ysed for creating
  the standardized naming identifiers in AWS resources and resource tags. You'll also
  find references to global_platform_shared_resource_identifier in the pre-configured helper bash scripts and the
  Terragrunt templates. global_platform_shared_resource_identifier is a short description identifying the
  name of the shared collection of AWS resources that support one or more Open edX environments. You'll see this identifier
  as a suffix to the AWS resource tag names of resources like AWS VPC, AWS EKS, AWS RDS MySQL, MongoDB, and Elasticache.

  *default value: service*

- **global_services_subdomain:**
  This cookiecutter will create several URL endpoints for each stack service, with
  each endpoint residing inside a common subdomain named global_services_subdomain.
  Examples include mysql.global_services_subdomain, mongodb.global_services_subdomain, redis.global_services_subdomain.

  *default value:  same as global_platform_shared_resource_identifier*

- **global_root_domain:**
  The fully-qualified domain name that will contain **ALL* URL endpoints. Example: yourschool.edu

- **global_aws_route53_hosted_zone_id:**
  The AWS Route53 Hosted Zone ID of the global_root_domain.
  Cookiecutter assumes that DNS is managed by AWS Route53. Note however that you can still use this cookiecutter
  even if you manage your DNS for the global_root_domain elsewhere. But, in either case you'll need to create a
  Route53 hosted zone for the global_root_domain which Terraform will reference when created additional hosted zones
  for the environment and stack subdomains.

  *Example: Z08529743UBLZ51RJDD76*

- **global_aws_region:**
  The `3-part character code <https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions>`_ for
  the AWS data center in which you'll deploy all AWS resources. You should choose the data center that is physically
  located nearest your learners.

  *default value: us-east-1*

- **global_account_id:**
  Your 12-character AWS account number.

  *Example: 123456789012*

- **global_platform_description:**
  The value assigned to edx-platform Django settings variable PLATFORM_DESCRIPTION.

  *default value: Your School*

- **global_platform_logo_url:**
  Future use.

  *default value: https://www.edx.org/images/logos/edx-logo-elm.svg*

Cookiecutter AWS Services Stack Installation Options
----------------------------------------------------

- **stack_install_k8s_dashboard:**
  'Y' to install `Kubernetes Dashboard <https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/>`_
  in the AWS EKS cluster and add an ingress, ssl-tls cert and url endpoint to global_services_subdomain.

  Dashboard is a web-based Kubernetes user interface. You can use Dashboard to deploy containerized applications to a Kubernetes cluster, troubleshoot your containerized application, and manage the cluster resources. You can use Dashboard to get an overview of applications running on your cluster, as well as for creating or modifying individual Kubernetes resources (such as Deployments, Jobs, DaemonSets, etc). For example, you can scale a Deployment, initiate a rolling update, restart a pod or deploy new applications using a deploy wizard.

  *default value: Y*

- **stack_install_k8s_kubeapps:**
  'Y' to install `VMWare Bitnami Kubeapps <https://kubeapps.dev/>`_
  in the AWS EKS cluster and add an ingress, ssl-tls cert and url endpoint to global_services_subdomain.

  Kubeapps is an in-cluster web-based application that enables users with a one-time installation to deploy, manage, and upgrade applications on a Kubernetes cluster

  *default value: Y*

- **stack_install_k8s_karpenter:**
  'Y' to install `Karpenter <https://karpenter.sh/>`_ in the AWS EKS cluster.

  Karpenter is an open-source project lead by AWS that provides just-in-time compute nodes for any Kubernetes cluster.
  Karpenter simplifies Kubernetes infrastructure with the right nodes at the right time.
  Karpenter automatically launches just the right compute resources to handle your cluster's applications. It is designed to let you take full advantage of the cloud with fast and simple compute provisioning for Kubernetes clusters.

  *default value: Y*

- **stack_install_k8s_prometheus:**
  'Y' to install `Prometheus <https://prometheus.io/`_ in the AWS EKS cluster. This is required if you chose
  to install Karpenter.

  *default value: Y*

- **stack_add_remote_mongodb:**
  'Y' to create an EC2 instance-based MongoDB server. This is recommended because we have encountered occasional compatibility issues with
  AWS DocumentDB.

  *default value: Y*

- **stack_add_bastion:**
  'Y' to create an EC2 instance-based Bastion server. This is strongly recommended. The bastion server provides an ssh private key based entry point to
  services that are only accessible from within your AWS Virtual Private Cloud (VPC). Additionally, the bastion server contains a curated collection of
  preinstalled and preconfigured software that you'll need for administering your Open edX installation.

  This option is required if you choose Y to stack_add_bastion_openedx_dev_environment.

  *default value: Y*

- **stack_add_bastion_openedx_dev_environment:**
  'Y' to include Open edX development essentials in the bastion configuration. These include for example,
  installing a version of Python that exactly matches that of your Open edX deployments, building a matching
  Python virtual environment and including misc apt packages that are requirements of the the PyPi packages included
  in the Python virtual environment.

  The bastion server provides several important software packages, some of which involve non-trivial configuration
  that might otherwise be challenging for you to install on your own:

  - homebrew
  - helm
  - Docker
  - tutor
  - aws cli
  - kubectl
  - k9s
  - terraform and terragrunt
  - mysql client software
  - mongodb client software

  *default value: N*

Cookiecutter AWS Services Stack Configuration Options
-----------------------------------------------------

AWS Elastics Kubernetes Service Configuration Options
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

eks_worker_group_instance_type: t3.xlarge
eks_worker_group_min_size: 0
eks_worker_group_max_size: 1
eks_worker_group_desired_size: 0
eks_karpenter_group_instance_type: t3.large
eks_karpenter_group_min_size: 3
eks_karpenter_group_max_size: 10
eks_karpenter_group_desired_size: 3
kubernetes_cluster_version: 1.24

MongoDB Configuration Options
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

mongodb_instance_type: t3.medium
mongodb_allocated_storage: 10

AWS EC2 Bastion Server Configuration Options
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

bastion_instance_type: t3.micro
bastion_allocated_storage: 50

AWS RDS MySQL Server Configuration Options
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

mysql_username: root
mysql_port: 3306
mysql_engine: mysql
mysql_family: mysql5.7
mysql_major_engine_version: 5.7
mysql_engine_version: 5.7.33
mysql_allocated_storage: 10
mysql_create_random_password: true
mysql_iam_database_authentication_enabled: false
mysql_instance_class: db.t2.small
mysql_maintenance_window: Sun:00:00-Sun:03:00
mysql_backup_window: 03:00-06:00
mysql_backup_retention_period: 7
mysql_deletion_protection: false
mysql_skip_final_snapshot: true

AWS Elasticache Redis Cluster Configuration Options
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

redis_engine_version: 6.x
redis_num_cache_clusters: 1
redis_node_type: cache.t2.small
redis_port: 6379
redis_family: redis6.x

Cookiecutter Github Actions Open edX Build Options
--------------------------------------------------

ci_build_tutor_version: 14.2.3
ci_build_open_edx_version: nutmeg.2
ci_build_theme_repository: edx-theme-example
ci_build_theme_repository_organization: lpm0073
ci_build_theme_ref: main
ci_build_plugin_org: lpm0073
ci_build_plugin_repository: openedx-plugin-example
ci_build_plugin_ref: main
ci_build_xblock_org: openedx
ci_build_xblock_repository: edx-ora2
ci_build_xblock_ref: master
ci_build_kubectl_version: 1.24/stable

Cookiecutter Github Actions Open edX Deploy Options
---------------------------------------------------
ci_deploy_install_backup_plugin: [N Y]
ci_deploy_install_credentials_server: [N Y]
ci_deploy_install_license_manager: [Y Y]
ci_deploy_install_discovery_service: [Y N]
ci_deploy_install_mfe_service: [Y N]
ci_deploy_install_notes_service: [Y N]
ci_deploy_install_ecommerce_service: [Y N]
ci_deploy_install_forum_service: [N Y]
ci_deploy_install_xqueue_service: [N Y]
ci_deploy_install_license_manager_service: [N Y]
ci_deploy_tutor_plugin_credentials_version: latest
ci_deploy_OPENEDX_COMMON_VERSION: open-release/{{ cookiecutter.ci_build_open_edx_version }}
ci_deploy_EMAIL_HOST: email-smtp.{{ cookiecutter.global_aws_region|lower|replace(' ' '-') }}.amazonaws.com
ci_deploy_EMAIL_PORT: 587
ci_deploy_EMAIL_USE_TLS: true

Cookiecutter Github Actions Configuration Options
-------------------------------------------------

ci_actions_setup_build_action_version: v2.2.1
ci_actions_amazon_ecr_login_version: v1.5.3
ci_actions_checkout_version: v3.2.0
ci_actions_configure_aws_credentials_version: v1.7.0
ci_openedx_actions_tutor_k8s_init_version: v1.0.4
ci_openedx_actions_tutor_k8s_configure_autoscaling_version: v0.0.1
ci_openedx_actions_tutor_k8s_configure_edx_secret_version: v1.0.0
ci_openedx_actions_tutor_k8s_configure_edx_admin: v1.0.1
ci_openedx_actions_tutor_k8s_configure_jwt_version: v1.0.0
ci_openedx_actions_tutor_k8s_configure_mysql_version: v1.0.2
ci_openedx_actions_tutor_k8s_configure_mongodb_version: v1.0.1
ci_openedx_actions_tutor_k8s_configure_redis_version: v1.0.0
ci_openedx_actions_tutor_k8s_configure_smtp_version: v1.0.0
ci_openedx_actions_tutor_print_dump: v1.0.0
ci_openedx_actions_tutor_plugin_build_backup_version: v0.1.7
ci_openedx_actions_tutor_plugin_build_credentials_version: v1.0.0
ci_openedx_actions_tutor_plugin_build_license_manager_version: v0.0.2
ci_openedx_actions_tutor_plugin_build_openedx_version: v1.0.2
ci_openedx_actions_tutor_plugin_build_openedx_add_requirement_version: v1.0.4
ci_openedx_actions_tutor_plugin_build_openedx_add_theme_version: v1.0.0
ci_openedx_actions_tutor_plugin_configure_courseware_mfe_version: v0.0.2
ci_openedx_actions_tutor_plugin_enable_backup_version: v0.0.10
ci_openedx_actions_tutor_plugin_enable_credentials_version: v1.0.0
ci_openedx_actions_tutor_plugin_enable_discovery_version: v1.0.0
ci_openedx_actions_tutor_plugin_enable_ecommerce_version: v1.0.2
ci_openedx_actions_tutor_plugin_enable_forum_version: v1.0.0
ci_openedx_actions_tutor_plugin_enable_k8s_deploy_tasks_version: v0.0.1
ci_openedx_actions_tutor_plugin_enable_license_manager_version: v0.0.3
ci_openedx_actions_tutor_plugin_enable_mfe_version: v0.0.1
ci_openedx_actions_tutor_plugin_enable_notes_version: v1.0.2
ci_openedx_actions_tutor_plugin_enable_s3_version: v1.0.2
ci_openedx_actions_tutor_plugin_enable_xqueue_version: v1.0.0

terraform_required_version: ~> 1.3
terraform_aws_modules_acm: ~> 4.3
terraform_aws_modules_cloudfront: ~> 3.1
terraform_aws_modules_eks: ~> 19.4
terraform_aws_modules_iam: ~> 5.9
terraform_aws_modules_iam_assumable_role_with_oidc: ~> 5.10
terraform_aws_modules_rds: ~> 5.2
terraform_aws_modules_s3: ~> 3.6
terraform_aws_modules_sg: ~> 4.16
terraform_aws_modules_vpc: ~> 3.18
terraform_helm_cert_manager: ~> 1.10
terraform_helm_ingress_nginx_controller: ~> 4.4
terraform_helm_vertical_pod_autoscaler: ~> 6.0
terraform_helm_karpenter: ~> 0.16
terraform_helm_dashboard: ~> 6.0
terraform_helm_kubeapps: latest
terraform_helm_metrics_server: ~> 3.8
terraform_helm_prometheus: ~> 43
terraform_provider_kubernetes_version: ~> 2.16
terraform_provider_hashicorp_aws_version: ~> 4.48
terraform_provider_hashicorp_local_version: ~> 2.2
terraform_provider_hashicorp_random_version: ~> 3.4
terraform_provider_hashicorp_kubectl_version: ~> 1.14
terraform_provider_hashicorp_helm_version: ~> 2.8
