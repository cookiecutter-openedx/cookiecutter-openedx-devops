## Terraform Modules

The Terraform modules in this folder are referenced by both `environments` as well as `stacks`. These are logical representations of actual AWS resources (ie services) that you will need in order to horizontally scale a Tutor installation of Open edX. Each component is a complete replacement to its local Tutor-based equivalent. That is, contrastly, simply installing Open edX with Tutor and then accepting all of its questionnaire default responses will result in Tutor implementing Docker containers for all of these services (MySQL, Mongo, Redis, etc.), all of which will run locally on the AWS EC2 instance on which you installed Tutor.

Since each of these represent AWS' premium service offering for each respective service (MySQL, MongoDB, Redis, etc), there are more options available to you. For example, each of these services can be independently sized. You can specifiy maintenance windows for automated upgrades, backup time windows and so forth.

Note that **you do not execute any of these Terraform scripts directly**. Quite the contrary, each of these modules is wired to its Terragrunt counterpart located in [terraform/environments/dev](terraform/environments/dev) and is called by Terragrunt.
