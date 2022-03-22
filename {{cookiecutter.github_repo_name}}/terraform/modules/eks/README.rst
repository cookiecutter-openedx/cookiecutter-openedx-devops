Amazon Elastic Kubernetes Service (EKS)
=======================================

This module uses the latest version of the community-supported `AWS EKS Terraform module <https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest>`_ to create a fully configured Kubernetes Cluster within the custom VPC. Features include:

- EC2 managed node group
- Fargate serverless compute cluster
- IRSA
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

- **Running at scale**. Use Fargate with Amazon ECS or Amazon EKS to easily run and scale your containerized data processing workloads. Fargate also enables you to migrate and run your Amazon ECS Windows containers without refactoring or rearchitecting your legacy applications.
- **Optimize Costs**. With AWS Fargate there are no upfront expenses, pay for only the resources used. Further optimize with `Compute Savings Plans <https://aws.amazon.com/savingsplans/compute-pricing/>`_ and `Fargate Spot <https://aws.amazon.com/blogs/aws/aws-fargate-spot-now-generally-available/>`_, then use `Graviton2 <https://aws.amazon.com/ec2/graviton/>`_ powered Fargate for up to 40% price performance improvements.
- Only pay for what you use. Fargate scales the compute to closely match your specified resource requirements. With Fargate, there is no over-provisioning and paying for additional servers.

How it works
~~~~~~~~~~~~

AWS Fargate is a serverless, pay-as-you-go compute engine that lets you focus on building applications without managing servers. AWS Fargate is compatible with both `Amazon Elastic Container Service (ECS) <https://aws.amazon.com/ecs/>`_ and `Amazon Elastic Kubernetes Service (EKS) <https://aws.amazon.com/eks/>`_.

.. image:: doc/diagram-fargate.png
  :width: 100%
  :alt: Fargate Diagram
