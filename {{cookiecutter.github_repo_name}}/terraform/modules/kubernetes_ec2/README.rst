Amazon Elastic Kubernetes Service (EKS)
=======================================

Implements a `Kubernetes Cluster <https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/>`_ via `AWS Elastic Kubernetes Service (EKS) <https://aws.amazon.com/eks/>`_. A Kubernetes cluster is a set of nodes that run containerized applications that are grouped in pods and organized with namespaces. Containerizing an application into a Docker container means packaging that app with its dependences and its required services into a single binary run-time file that can be downloaded directly from the Docker registry.
Our Kubernetes Cluster resides inside the VPC on a private subnet, meaning that it is generally not visible to the public. In order to be able to receive traffic from the outside world we implement `Kubernetes Ingress Controllers <https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/>`_ which in turn implement a `Kubernetes Ingress <https://kubernetes.io/docs/concepts/services-networking/ingress/>`_
for both an `AWS Application Load Balancer <https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html>`_ as well as our `Nginx proxy server <https://www.nginx.com/>`_.

Implementation Strategy
-----------------------

Our goal is to, as much as possible, implement a plain vanilla Kubernetes Cluster that generally uses all default configuration values and that includes EC2 as well as Fargate compute nodes.

This module uses the latest version of the community-supported `AWS EKS Terraform module <https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest>`_ to create a fully configured Kubernetes Cluster within the custom VPC.
AWS EKS Terraform module is widely supported and adopted, with more than 250 open source code contributers, and more than 10 million downloads from the Terraform registry as of March, 2022.

How it works
------------

Amazon Elastic Kubernetes Service (Amazon EKS) is a managed container service to run and scale Kubernetes applications in the cloud. It is a managed service, meaning that AWS is responsible for up-time, and they apply periodic system updates and security patches automatically.

.. image:: doc/diagram-eks.png
  :width: 100%
  :alt: EKS Diagram
