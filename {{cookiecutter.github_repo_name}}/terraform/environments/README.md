## Terragrunt Environments

Terraform environments give you the ability to create multiple, distinct AWS VPC clouds for prod, development, QA and so on. That is, you would be create distinct RDS instances, MongoDB instances, Kubernetes Cluster instances and so on; one for each additional environment.

The general strategy is that a common set of parameters are defined in [terraform/environments/global.hcl](./global.hcl) that each environment uses, plus, each environment maintains its own set of parameters for environment-specific settings like domain names and resource instances sizes for example.

The difference between these two methodologies is that the former creates an entire VPC per environment, increasing your monthly AWS bill by multiples, whereas the latter simply adds additional domain records, S3 buckets, and logical databases as necessary to support the additional environments.

### Why would you create an additional Terragrunt environment?

1. You would take this approach if, for example, internal policy at your organization dictactates that developers and qa staff **must** be completely isolated from your prod environment. That is precisely what an additional Terragrunt environment provides for you. This affords you absolute separation between environemnts, but at significantly higher AWS cost and more support burden on you.

2. An alternative scenario would be that, for quality-of-service reasons, you want to completely separate a large MOOC from the course content that you offer to regularly-enrolled students. To accomplish this you could use the **prod** environement created by Cookiecutter for your enrolled students, and then create a second environment named **mooc**.
