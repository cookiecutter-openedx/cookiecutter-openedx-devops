# Environments

Cookiecutter environments give you the ability to create multiple, segregated operating environments for your Open edX installation, saving you time and effort in creating and maintaining environments for `prod`, `dev`, `test`, `qa`, `mcdaniel`, etcetera. Cookiecutter environments run on a [backend stack](../stacks/).

Cookiecutter environments are logically separated, using their own sets of:

- cloud storage and data backup locations
- logical MySQL databases and MongoDB contentstores
- Redis cache keys
- application credentials and service accounts
- domain name and DNS entries
- ssl certificates
- ingresses
- Kubernetes namespaces and resource monitoring configurations
- Github Action build-deploy workflows
