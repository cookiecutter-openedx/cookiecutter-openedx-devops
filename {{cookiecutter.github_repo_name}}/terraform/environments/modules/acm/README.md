# Amazon Certificate Manager

Requests ssl certificates for stack aws_region {{ cookiecutter.global_platform_region }} for ELB, adds DNS records for certificate verification, and adds a certificate to us-east-1 for AWS Cloudfront distributions.

## Additional Features

This module integrates [cookiecutter_meta](../../../common/cookiecutter_meta/README.md), which manages an optional additional set of AWS resource tags.
