## Terragrunt Environments

Terraform environments give you the ability to create multiple, distinct AWS VPC clouds for prod, development, QA and so on. That is, you would be create distinct RDS instances, MongoDB instances, Kubernetes Cluster instances and so on; one for each additional environment.

The envisioned implementations of additional environments would consist of environments like: `prod`, `dev`, `test`, `qa`, `mcdaniel`, etcetera.

These additional environments will run on shared infrastructure, named `live` by default, unless you have specified otherwise. However, each environment has its own data and its own Kubernetes namespace.

The general strategy is that a common set of parameters are defined in [terraform/environments/global.hcl](./global.hcl) that each environment uses, plus, each environment maintains its own set of parameters for environment-specific settings like domain names and resource instances sizes for example.

The difference between these two methodologies is that the former creates an entire VPC per environment, increasing your monthly AWS bill by multiples, whereas the latter simply adds additional domain records, S3 buckets, and logical databases as necessary to support the additional environments.
