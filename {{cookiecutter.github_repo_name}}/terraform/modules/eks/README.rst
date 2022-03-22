AWS Elastic Kubernetes Service (EKS)
====================================================================================================

This module uses the latest version of the community-supported `AWS EKS Terraform module <https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest>`_ to create a fully configured Kubernetes Cluster within the custom VPC. Features include:

- EC2 managed node group
- Fargate serverless compute cluster
- IRSA
- Private access to all resources contained in the VPN
- Kubernetes secrets encryption

see:

    https://www.youtube.com/watch?v=oYHZ3EPR094&t=1093s
    https://github.com/antonputra/tutorials/tree/main/lessons/038/

    https://www.youtube.com/watch?v=MZyrxzb7yAU
    https://antonputra.com/terraform/how-to-create-eks-cluster-using-terraform/
    https://github.com/antonputra/tutorials/tree/main/lessons/102


Other documentation
-------------------

.. image:: doc/aws_eks_fargate.png
  :width: 100%
  :alt: AWS EKS Fargate Diagram


.. image:: doc/aws-vpc-eks.png
  :width: 100%
  :alt: AWS VPC EKS Diagram


.. image:: doc/node_group-diagram.jpeg
  :width: 100%
  :alt: AWS EKS Node Group Diagram
