# Environment Specific MySQL Configuration

Creates environment specific configuration for the Stack-level [AWS RDS MySQL](https://aws.amazon.com/rds/) service. Creates the following resources:

- Kubernetes secret with MySQL host, port, username, password
- DNS record added to the environment AWS Route53 Hosted Zone

## Additional Features

This module integrates [cookiecutter_meta](../../../common/cookiecutter_meta/README.md), which manages an optional additional set of AWS resource tags.
