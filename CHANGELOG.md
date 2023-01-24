# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [1.0.18] (2023-1-23)

- convert defalt stack certificate.yml to a template to parameterize name and namespace
- ensure that the secret name of all cert requests matches the domain name of the request itself

## [1.0.17] (2023-1-21)

- add aws eks update-kubeconfig call ahead of annotating service account for AWS EBS CSI Driver
- add Terraform outputs to environments/modules/acm so that Terragrunt run-all won't complain
- parameterize environment ingress and certificate manifests
- parameterize REDIS_KEY_PREFIX in redis environment configuration

## [1.0.16] (2023-1-17)

- add a kms_key_owners list to AWS EKS stack
- add Cookiecutter parameter documentation

## [1.0.15] (2023-1-16)

- move redis module from environment to stack
- add tags to all redis resources
- fix all redis module deprecation warnings
- refactor redis security group from module to direct terraform resource declaration

## [1.0.14] (2023-1-15)

- set stack mysql k8s secret HOST to route53 subdomain
- add a more complete set of outputs to each stack module
- add missing cluster name and namespace to build workflow
- add complete mock inputs and dependency declarations through environment hcl files.

## [1.0.13] (2023-1-14)

- minor bug fixes after fully testing a build from scratch.
- ensure that sudo apt get install operations do not solicit input

## [1.0.12] (2023-1-13)

- refactor environment tags
- parameterize stack name references in environment modules
- remove nginx vpa manifest from environment ingress module

## [1.0.11] (2023-1-12)

- refactor AWS resource tags
- set global_platform_shared_resource_identifier=service
- bugs fixes related to refactoring of bastion, MongoDB, and Kubernetes
- refine Terragrunt Kubernetes dependencies

## [1.0.10] (2023-1-12)

- refactor endpoints for all stack services: mysql, mongodb, redis, grafana, dashboard, kubeapps
- refactor aws resource tags to format of "cookiecutter/name-of-the-tag"
- rename Cookiecutter default global_platform_shared_resource_identifier=service
- move VPA manifest for metrics-server to kubernetes_vpa, since its a dependency
- pin each EKS Add-On version
- enhance Terragrunt stack dependency tree
- remove nginx ingress CLB DNS records from root domain

## [1.0.9] (2023-1-11)

- refactor Prometheus into its own module
- refactor metrics-server into its own module
- refactor Vertical Pod Autoscaler into its own module
- bump all Helm chart versions
- add more Cookiecutter parameters

Note: this concludes the Kubernetes refactoring exercise. Happy new year!

## [1.0.8] (2023-1-9)

- refactor karpenter into its own module.
- parameterize helm chart version of vertical-pod-autoscaler
- add Cookiecutter Y/N install parameters to toggle optional Kubernetes features: Karpenter, Prometheus, Dashboard, Kubeapps

## [1.0.7] (2023-1-8)

- refactor cert-manager into its own module and move from environment to stack.
- Move cert-manager to its own namespace
- bump cert-manager to v1.8.2
- bump ingress-nginx-controller to 4.4.2 and parameterize version
- standardize and consolidate ssl cert to a single secret
- refactor all non-core kubernetees packages into a new Terraform module named kubernetes_monitoring
- created new subdomain to host all admin software packages
- add Kubernetes Dashboard web app
- add kubeapps by VMWare + Bitnami
- move grafana to new admin subdomain
- deprecated Github Action openedx-actions/tutor-plugin-enable-mfe
- deprecated Github Action openedx-actions/tutor-plugin-build-mfe
- version bumps to all Terraform AWS modules https://registry.terraform.io/namespaces/terraform-aws-modules
- version bumps to all Open edX Github Actions https://github.com/openedx-actions

## [1.0.6] (2023-1-7)

- version bumps
- add sql db migration scripts
- Fix openedx_backup resource configuration
- refactor build-deploy workflows for tutor upgrade
- disable tutor web proxy to elminate unused EBS volume
- add IAM Role for EKS add-on EBS CSI
- add AmazonEBSCSIDriverPolicy to the karpenter node group
- add more parameters to openedx-actions/tutor-k8s-init

## [1.0.5] (2022-12-11)

- bump to K8s 1.24
- version bumps to all Terraform AWS modules https://registry.terraform.io/namespaces/terraform-aws-modules
- version bumps to all Open edX Github Actions https://github.com/openedx-actions
- refactor cert-manager for v1.9

## [1.0.4] (2022-09-02)

- bump to nutmeg.2
- bump tutor to 14.0.5
- tie optional repo build & deployment features to new Y/N flags in Cookiecutter
- add docker ce and python3 to bastion install.sh script
- add installed application versions to bastion login screen

## [1.0.3] (2022-08-29)

- add an option to create a remote MongoDB server running on a standalone EC2 instance.

## [1.0.2] (2022-08-18)

- reconfigure k8s node groups to use [AWS SPOT Pricing](https://aws.amazon.com/ec2/spot/pricing/) for EC2 instances
- add k8s [metrics-server](https://github.com/kubernetes-sigs/metrics-server)
- add [Prometheus](https://prometheus.io/)
- add [Grafana](https://grafana.com/)
- add [Karpenter](https://karpenter.sh/)
- add k8s [Horizontal Pod Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) for all Open edX pods
- add k8s [Vertical Pod Autoscaling](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler) for all Open edX pods
- add AWS S3 encrypted bucket to store e-commerce payment processor api keys and secrets


## [1.0.1] (2022-06-26)

- add per-environment mysql db names
- add openedx-actions/tutor-plugin-configure-courseware-mfe
- add openedx-actions/tutor-plugin-enable-k8s-deploy-tasks
- misc security patches
- add a bastion setup script to install tutor, kubectl, terraform, terragrunt
- bump most openedx-actions to production
- enhanced k8s administration documentation

## [1.0.0] (2022-06-16)

General production release
## [0.2.0] (2022-06-10)

- refactor for tutor 14.x
- bump to open-release/nutmeg.1

## [0.1.4] (2022-06-06)

- Refactor Github workflows to use [openedx-actions](https://github.com/openedx-actions)

## [0.1.3] (2022-05-30)

- bump all Terraform versions

## [0.1.1] (2022-05-26)

- Adds the plugin installation
- adds Terraform code to create a dedicated private S3 bucket for backups

## [0.1.0] (2022-05-24)

- Terraform
  - bumped all version
- Deployment workflow
  - bumped all versions
  - Added installation options for Credentials, Ecommerce, MFE, Discovery, Notes, Forum, Xqueue
- Stacks
  - Introduced shared infrastructure stacks consisting of a private VPC, EKS K8S and an option EC2 Bastion. This collection of resources is configured to host external non-openedx platforms such as for example, your custom micro services or a content management system.
- AWS Services
  - Bastion: full Bastion management including creation and storage of ssh key
  - K8s:  added a namespace for shared secrets: Bastion ssh key, MySQL root credentials
  - RDS: Added storage auto-scaling
  - Mongo: reverted to Tutor-installed MongoDB pod on k8s

## [0.0.5]

- removed subdomains list

## [0.0.4]

- parameterized deployment yaml manifests with cookiecutter
- refactored VPC and EKS modules based on the current latest version of terraform-aws-modules modules
- upgraded AWS RDS Terraform module to v4
- added AWS certficates in us-east-1 and the aws region specified in environments/global.hcl
- added new module for Cloudfront distribution and DNS record for 'cdn' subdomain
- added new optional module for EC2 Bastion and DNS record for subdomain
- added version constraint parameters to cookiecutter for all terraform-aws-modules
- added mock outputs to terragrunt scripts to facilitate `run-all` init and validate operations in environments
- added this change log
- resolved deprecation warnings in all modules
- restructured terraform folders
- fixed a bug that was causing multiple SSL/TLS certificates to be created in both us-east-1 as well as the environment region
- added the text 'openedx_devops' to the descriptions of all security groups, IAM roles, and IAM policies resources that are explicitly created by this repository


## [0.0.3] - 2022-03-20

- added Cookiecutter parameters for environment_subdomain, ci_deploy_open_edx_version, ci_build_tutor_version, all teraform version constraints
- split environment_name and environment_subdomain
- added Cookiecutter post hook to process selection of EKS Load Balancer configuration
- added scripts to make, test, lint
- more sensible defaults in cookiecutter.json
- expanded README.md documentation
- added git pre-commit
- added AUTHORS.md

## [0.0.2] - 2022-03-11

- Additional documentation

## [0.0.1] - 2022-03-10

Initial release
