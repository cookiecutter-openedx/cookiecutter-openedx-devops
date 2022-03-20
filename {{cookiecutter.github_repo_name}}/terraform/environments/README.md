## Terragrunt Environments

Terraform environments give you the ability to create multiple, distinct AWS VPC clouds for prod, development, QA and so on. That is, you would be create distinct RDS instances, MongoDB instances, Kubernetes Cluster instances and so on; one for each additional environment.

The general strategy is that a common set of parameters are defined in [terraform/environments/global.hcl](./global.hcl) that each environment uses, plus, each environment maintains its own set of parameters for environment-specific settings like domain names and resource instances sizes for example.

On an aside, choosing appropriate names for Terragrunt environments was a struggle. the environment named **prod** in this folder was originally named **live** as a means of differentiating it from alternative environments like say, **sandbox**. This was sensible, but it also complicates managing consistent namespaces in AWS and in Kubernetes. We opted to rename this to **prod** since Cookiecutter only creates one single environment for you, and this is where your prod environment resides. Unfortunately, this creates some potential confusion given that the recommended way of creating dev / qa / test environments is to add appropriately named subdomains to prod.

So, to be clear, creating additional Terragrunt environments might be more separation than you actually require, and add more costs than your budget can bear. Keep in mind that this is probably more easily accomplished simply by adding subdomains to the one VPC that is created based on the settings in [terraform/environments/prod/env.hcl](./prod/env.hcl), as follows:

```
locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  environment           = "{{ cookiecutter.environment_name }}"
  subdomains            = ["dev", "test", "qa", "lawrence-dev", "frank-dev"]
}```

The difference between these two methodologies is that the former creates an entire VPC per environment, increasing your monthly AWS bill by multiples, whereas the latter simply adds additional domain records, S3 buckets, and logical databases as necessary to support the additional environments.

### Why would you create an additional Terragrunt environment?

1. You would take this approach if, for example, internal policy at your organization dictactates that developers and qa staff **must** be completely isolated from your prod environment. That is precisely what an additional Terragrunt environment provides for you. This affords you absolute separation between environemnts, but at significantly higher AWS cost and more support burden on you.

2. An alternative scenario would be that, for quality-of-service reasons, you want to completely separate a large MOOC from the course content that you offer to regularly-enrolled students. To accomplish this you could use the **prod** environement created by Cookiecutter for your enrolled students, and then create a second environment named **mooc**.

### Why wouldn't you create an additional Terragrunt environment?

Contrastly, if you are budget conscious and you are otherwise indifferent to how and where your development and qa environments are housed -- provided of course that these are reasonably isolated from your prod environment -- then you would simply add subdomains to [terraform/environments/prod/env.hcl](terraform/environments/prod/env.hcl).
