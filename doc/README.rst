Project Generation Option
=========================


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
  named environment_name and located in the file path terraform/environments/environment_name.
  You'll find extensive references to environment_name throughout terraform/environments/modules.
  Note that you can copy-paste this folder to create additional environments.

  *default value: prod*

- **environment_subdomain:**
  This cookiecutter will create several URL endpoints for each environment_name, with
  each endpoint residing inside a common subdomain named environment_subdomain.

  *default value: courses*

environment_studio_subdomain: studio
global_platform_name: yourschool
global_platform_description: Your School
global_platform_logo_url: https://www.edx.org/images/logos/edx-logo-elm.svg
global_platform_region: global
global_platform_shared_resource_identifier: service
global_services_subdomain: {{ cookiecutter.global_platform_shared_resource_identifier|lower|replace(' ' '-') }}
global_root_domain: {{ cookiecutter.global_platform_name|lower|replace(' ' '-') }}.edu
global_aws_route53_hosted_zone_id: Z1234567ABCDE1U23DEF
global_aws_region: us-east-1
global_account_id: 123456789012
stack_install_k8s_dashboard: [Y N]
stack_install_k8s_kubeapps: [Y N]
stack_install_k8s_karpenter: [Y N]
stack_install_k8s_prometheus: [Y N]
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
eks_worker_group_instance_type: t3.xlarge
eks_worker_group_min_size: 0
eks_worker_group_max_size: 1
eks_worker_group_desired_size: 0
eks_karpenter_group_instance_type: t3.large
eks_karpenter_group_min_size: 3
eks_karpenter_group_max_size: 10
eks_karpenter_group_desired_size: 3
kubernetes_cluster_version: 1.24
stack_add_remote_mongodb: [Y N]
mongodb_instance_type: t3.medium
mongodb_allocated_storage: 10
stack_add_bastion: [Y N]
stack_add_bastion_openedx_dev_environment: [N Y]
bastion_instance_type: t3.micro
bastion_allocated_storage: 50
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
redis_engine_version: 6.x
redis_num_cache_clusters: 1
redis_node_type: cache.t2.small
redis_port: 6379
redis_family: redis6.x
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