# Cookiecutter Meta

Collects and persists meta data about the current user's environment. Data collected is made visible to Terraform by persisting each data element its own .state file in ./output. These files in turn are exposed within Terraform using "data" declarations.

Cookiecutter Meta is referenced by all modules contained in [environments](../../environments/) and [stacks](../../stacks/) and is ultimated formatted into AWS resource tag elements that are persisted into every AWS resource created by the Terraform scripts contained in this repository.

## Meta Data

Collects the following about your operating environment:

- AWS Command-line interface version number
- The current git branch of this repository
- The most recent git commit date from this repository
- The sha of the most recent git commit from this repository
- The AWS IAM ARN which contains the key-secret in use for the awscli
- Kubectl current version
- The name and version of your computer's operating system
- Terraform current version
- Timestamp of the last time this module was executed
- Cookiecutter version

## Usage

Run this module separately and as needed.

```bash
  terraform init    # prepare this module to run by downloading all referenced Terraform modules and providers
  terraform plan    # echo a work plan to the console
  terraform apply   # run this module
```
