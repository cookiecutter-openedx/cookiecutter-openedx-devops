# Environment Specific Kubernetes Ingress

Implements an Nginx-based ingress controller and AWS Classic Load Balancer for this environment. Creates the following resources:

- Helm installed Certificate Issuer which relies on Kubernetes [cert-manager](https://cert-manager.io/)
- Open edX ingresses for lms, cms, discovery
- Open edX [MFE](https://openedx.atlassian.net/wiki/spaces/FEDX/pages/1265467645/Open+edX+and+Microfrontends) ingress
- DNS records added to AWS Route53 Hosted Zone for this environment

## Additional Features

This module integrates [cookiecutter_meta](../../../common/cookiecutter_meta/README.md), which manages an optional additional set of AWS resource tags.
