## Terragrunt Stacks

Terraform stacks give you the ability to create multiple distinct collections
of AWS shared infrastructure for VPC, EKS, RDS and EC2 Bastion access. In most
cases you'll only want the one "live" stack that is created by default.

The general strategy is that a common set of parameters are defined in [terraform/environments/global.hcl](./global.hcl) that each stack uses, plus, each stack maintains its own set of parameters for stack-specific settings like domain names and resource instances sizes for example.

The difference between these two methodologies is that the former creates an entire VPC per stack, increasing your monthly AWS bill by multiples, whereas the latter simply adds additional domain records, S3 buckets, and logical databases as necessary to support the additional environments.

### Why would you create an additional Terragrunt stack?

1. You would take this approach if, for example, internal policy at your organization dictactates that developers and qa staff **must** be completely isolated from your live stack. That is precisely what an additional Terragrunt stack provides for you. This affords you absolute separation between environemnts, but at significantly higher AWS cost and more support burden on you.

2. An alternative scenario would be that, for quality-of-service reasons, you want to completely separate a large MOOC from the course content that you offer to regularly-enrolled students. To accomplish this you could use the **live** stack created by Cookiecutter for your enrolled students, and then create a second stack named **mooc**.
