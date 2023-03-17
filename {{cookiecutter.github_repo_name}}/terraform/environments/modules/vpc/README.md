# Environment Specific Virtual Private Cloud Configuration

Creates the following environment specific resources inside of the stack-level Virtual Private Cloud:

- AWS Route53 Hosted Zone for management of the environment subdomain
- DNS NS records to link the AWS Route53 Hosted zone to the root domain

## Note the following


## Additional Features

This module integrates [cookiecutter_meta](../../../common/cookiecutter_meta/README.md), which manages an optional additional set of AWS resource tags.
