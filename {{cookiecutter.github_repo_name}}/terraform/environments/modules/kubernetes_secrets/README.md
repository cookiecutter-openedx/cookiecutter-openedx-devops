# Environment Specific Open edX Credentials

Creates Kuberenetes secrets for the following Open edX passwords and credentials in this environment:

- Open edX admin user account name and password
- ecommerce-config
- Django application edx-secret-key for this environment
- Javascript Web Token (jwt) for lms and cms for this environment
- Open edX License Manager oauth for this environment
- MongoDB host name, port, admin account name and password for this stack
- MongoDB host name, port, openedx account name and password for this environment
- MySQL host name, port, openedx account name and password for this environment
- MySQL host name, port, Discovery Service account name and password for this environment
- MySQL host name, port, Xqueue Service account name and password for this environment
- MySQL host name, port, root account name and password for this stack
- Redis host name, port, environment key
- AWS IAM key-secret for read-write access to AWS S3 buckets for this environment

## Additional Features

This module integrates [cookiecutter_meta](../../../common/cookiecutter_meta/README.md), which manages an optional additional set of AWS resource tags.
