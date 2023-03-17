# Environment Specific AWS ElastiCache Redis Configuration

Creates environment specific configuration for the Stack-level MonogDB service. Creates the following resources:

- Kubernetes secret with [AWS ElastiCache](https://aws.amazon.com/elasticache/) Redis Service host, port, username, password
- DNS record added to the environment AWS Route53 Hosted Zone

## Additional Features

This module integrates [cookiecutter_meta](../../../common/cookiecutter_meta/README.md), which manages an optional additional set of AWS resource tags.
