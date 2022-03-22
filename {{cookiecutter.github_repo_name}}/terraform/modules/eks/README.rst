Amazon Elastic Kubernetes Service (EKS)
=======================================

This module uses the latest version of the community-supported `AWS EKS Terraform module <https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest>`_ to create a fully configured Kubernetes Cluster within the custom VPC.
AWS EKS Terraform module is widely supported and adopted, with more than 250 open source code contributers, and more than 10 million downloads from the Terraform registry as of March, 2022.

Our goal is to, as much as possible, implement a plain vanilla Kubernetes Cluster that generally uses all default configuration values and that includes EC2 as well as Fargate compute nodes

Features include:

- EC2 managed node group
- Options for either EC2 or Fargate serverless compute cluster
- IRSA
- preconfigured OICD provider
- preconfigured IAM policies and roles
- Private access to all resources contained in the VPN
- Kubernetes secrets encryption

How it works
------------

Amazon Elastic Kubernetes Service (Amazon EKS) is a managed container service to run and scale Kubernetes applications in the cloud. It is a managed service, meaning that AWS is responsible for up-time, and they apply periodic system updates and security patches automatically.

.. image:: doc/diagram-eks.png
  :width: 100%
  :alt: EKS Diagram


AWS Fargate Serverless compute for containers
---------------------------------------------

AWS Fargate is a serverless, pay-as-you-go computing alternative to traditional EC2 instance-based computing nodes. It is compatible with both `Amazon Elastic Container Service (ECS) <https://aws.amazon.com/ecs/>`_ and `Amazon Elastic Kubernetes Service (EKS) <https://aws.amazon.com/eks/>`_.
There are two distinct benefits to using Fargate instead of EC2 instances. First is cost. Similar to AWS Lambda, you only pay for the compute cycles that you consume. Most Open edX installations provision server infrastructure based on peak load estimates, which in point of fact only occur occasionally, during isolated events like approaching homework due dates, mid-term exams and so on. This in turn leads to EC2 instances being under-utilized most of the time.
Second, related, is scaling. Fargate can absorb whatever workload you send to it, meaning that during peak usage periods of your Open edX platform you won't need to worry about provisioning additional EC2 server capacity.


- **Running at scale**. Use Fargate with Amazon ECS or Amazon EKS to easily run and scale your containerized data processing workloads.
- **Optimize Costs**. With AWS Fargate there are no upfront expenses, pay for only the resources used. Further optimize with `Compute Savings Plans <https://aws.amazon.com/savingsplans/compute-pricing/>`_ and `Fargate Spot <https://aws.amazon.com/blogs/aws/aws-fargate-spot-now-generally-available/>`_, then use `Graviton2 <https://aws.amazon.com/ec2/graviton/>`_ powered Fargate for up to 40% price performance improvements.
- Only pay for what you use. Fargate scales the compute to closely match your specified resource requirements. With Fargate, there is no over-provisioning and paying for additional servers.

How it works
~~~~~~~~~~~~

.. image:: doc/diagram-fargate.png
  :width: 100%
  :alt: Fargate Diagram
