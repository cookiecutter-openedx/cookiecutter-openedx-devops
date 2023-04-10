# Tutor Deploy to EKS With CLB

## How it works

All the logic is defined in the actual workflow. It mostly follows the steps outlined on  Tutor's documentation with some adaptations to run it in a disposable CI environment.

When running the Tutor CLI on a local machine it can run in an interactive mode and persists the captured config into a local file. In the context of a CI job, such as GitHub Actions, this is not possible.

Luckily the Tutor CLI allows all of it's params to be passed as a command line argument, or as an environment variable. We leverage this feature to provide all the custom details, from external sources.


## Dependencies

This workflow needs to collect some parameters for Tutor from external sources, such as credentials and endpoints from backing services. As a rule of thumb these are fetched from a predefined Kubernetes secret resource on the target namespace for the environment.

Also, the backing services need to be readily available prior to deploying the Open edX platform, because Tutor and the workflow will need to run several initialisation tasks; Django database migrations for example.

All the necessary dependencies need to be deployed prior to deploying an environment for the first time using the terraform stack.

The Terraform stack will create all of the resources needed for this deployment workflow to operate and deliver a running edX platform.

- Kubernetes namespace
- Mysql database (RDS)
- ElasticSearch (AWS ElasticSearch) -- MCDANIEL: REMOVED FEB-2022
- Redis (AWS ElasticCache Redis)
- S3 Bucket
- Kubernetes' secrets containing the locations and credentials for all the above AWS services and others


## Deployment process

Once the Terraform stack with the Open edX dependencies has been successfully applied for a particular Open edX environment (one-off) we just need to trigger the desired environment's workflow dispatch.

### Repository structure

This repository contains a directory `environemnts` with the following structure

Taking the `dev` environment as an example, the file structure looks like this:

```bash
└── environments
├── dev
│   ├── config.yml
│   ├── k8s
│   │   ├── cluster-issuer.yml
│   │   └── ingress.yml
│   └── settings_merge.json
```

#### config.yml

This file contains a few entries that will be fed into early the Tutor configuration stage.
These are the FQDNs of the LMS and CMS applications of Open edX and the location of the custom image that we build.

#### k8s

This is a directory that contains predefined Kubernetes resources to deploy edX


     ├── cluster-issuer.yml
     └── ingress.yml

This is a definition of a ClusterIssuer and a TLS Certificate.
These resources create a Kubernetes ingress with TLS support and generate a TLS certificate to match the associated domain.
They are applied and enforced during the deployment.

#### settings_merge.json

This file contains custom configuration that is not managed by Tutor, but that we need to add to the running Open edX services so that our plugin can work.

We cannot tell Tutor to include extra configuration or settings that it does not manage,
so we will merge this JSON block to the final rendered configuration that will be passed on to the edX services ,the LMS and the CMS.
