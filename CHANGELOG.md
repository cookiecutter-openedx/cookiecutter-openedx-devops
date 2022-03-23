# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).


## [0.1.0]

- added this change log
- restructured terraform folders
- parameterized deployment yaml manifests with cookiecutter
- refactored VPC and EKS modules based on the current latest version of terraform-aws-modules modules
- added a Fargate profile to EKS
- added an ingress AWS Application Load Balancer controller to EKS
- added AWS certficates in us-east-1 and the aws region specified in environments/global.hcl
- added Cloudfront distribution and DNS record for 'cdn' subdomain
- added MySQL backup to nightly backup job
- added version constraint parameters to cookiecutter for all terraform-aws-modules


## [0.0.3] - 2022-03-20

- added Cookiecutter parameters for environment_subdomain, ci_build_open_edx_version, ci_build_tutor_version, all teraform version constraints
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
