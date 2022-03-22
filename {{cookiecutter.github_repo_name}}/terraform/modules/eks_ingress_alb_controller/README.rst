Terraform module: AWS Load Balancer Controller installation
============================================================================

This module installs the optional AWS Load Balancer (ALB) Controller into our Kubernetes cluster.
The `AWS Load Balancer Controller <https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/>`_ that we're installing is an open-source project with broad community support.
As of March, 2022 there have been 43 million downloads of this controller from the Kubernetes Registry, and the project itself is supported by more than 100 individual contributors.

Implementation strategy
-----------------------

The AWS Load Balancer Controller `installation process <https://aws.amazon.com/blogs/opensource/kubernetes-ingress-aws-alb-ingress-controller/>`_ is complex.
Fortunately however, the `U.S. General Services Administration (GSA) <https://open.gsa.gov>`_ modularized and `open-sourced their implementation <https://github.com/GSA/terraform-kubernetes-aws-load-balancer-controller>`_ which is quite robust and well maintained. You can view the implemntation in its entirety, `here <https://github.com/GSA/terraform-kubernetes-aws-load-balancer-controller/blob/main/main.tf>`_.
Conveniently, this higher-order Terraform module exposes all of the parameters that we need for our purposes.

GSA's implementation leverages the Terraform package manager `Helm <https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller>`_ to install the AWS Load Balancer (ALB) Controller which itself simplifies the installation somewhat.
Nonetheless, on further inspection of GSA's module you'll see that they create multiple security and access related IAM resources, and then associate these
to the ALB controller, all of which requires vendor-specific syntax that would otherwise have been tedious to figure out. Resources created by GSA's installation module include:

- **aws_iam_role** for the AWS ALB to be able to create resources like EC2 instances, among other things
- **aws_iam_policy** to associate with the AWS ALB IAM role. The policy itself is quite granular and goes to great lengths to avoid granting permissions that are not necessary.
- **kubernetes_service_account** and kubernetes_cluster_role that enable the ALB to interact with EKS

Configuring the ALB
~~~~~~~~~~~~~~~~~~~

The specifics of our ALB configuration are implemented with a single dictionary in `main.tf <./main.tf>`_ named k8s_pod_annotations.

How it works
------------

`Kubernetes Ingress <https://kubernetes.io/docs/concepts/services-networking/ingress/>`_ is an API resource that allows you manage external or internal HTTP(S) access to `Kubernetes services <https://kubernetes.io/docs/concepts/services-networking/service/>`_ running in a cluster. `Amazon Elastic Load Balancing Application Load Balancer (ALB) <https://aws.amazon.com/elasticloadbalancing/features/#Details_for_Elastic_Load_Balancing_Products>`_ is a popular AWS service that load balances incoming traffic at the application layer (layer 7) across multiple targets, such as Amazon EC2 instances, in a region. ALB supports multiple features including host or path based routing, TLS (Transport Layer Security) termination, WebSockets, HTTP/2, AWS WAF (Web Application Firewall) integration, integrated access logs, and health checks.

The open source `AWS ALB Ingress controller <https://github.com/kubernetes-sigs/aws-alb-ingress-controller>`_ triggers the creation of an `ALB <https://aws.amazon.com/elasticloadbalancing/features/#Details_for_Elastic_Load_Balancing_Products>`_ and the necessary supporting AWS resources whenever a Kubernetes user declares an Ingress resource in the cluster. The Ingress resource uses the ALB to route HTTP(S) traffic to different endpoints within the cluster. The AWS ALB Ingress controller works on any Kubernetes cluster including Amazon Elastic Kubernetes Service (`Amazon EKS <https://aws.amazon.com/eks/>`_).

How Kubernetes Ingress works with aws-alb-ingress-controller
------------------------------------------------------------

Design
~~~~~~

`AWS Load Balancer Controller Kubernetes Technical documentation <https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/how-it-works/>`_

The following diagram details the AWS components that the aws-alb-ingress-controller creates whenever an Ingress resource is defined by the user. The Ingress resource routes ingress traffic from the ALB to the Kubernetes cluster. It also demonstrates the route ingress traffic takes from the ALB to the Kubernetes cluster.

.. image:: doc/aws-alb-ingress-controll.png
  :width: 100%
  :alt: How AWS Load Balancer controller works

.. role:: bash(code)
   :language: bash

.. role:: kubernetes(code)
   :language: kubernetes

Ingress Creation
~~~~~~~~~~~~~~~~

Following the steps in the numbered blue circles in the above diagram:

**[1]**: The alb ingress controller watches for ingress events from the Kubernetes API server. Ingress events originate from this Terraform code, when you run :bash:`terragrunt apply` or :bash:`terragrunt destroy`. When it finds ingress resources that satisfy its requirements, it begins the creation of AWS resources.

**[2]**: An Application Load Balancer (ALB) is created in AWS for the new ingress resource. This ALB can be internet-facing or internal. You can also specify the subnets it's created in using annotations.

**[3]**: Target Groups are created in AWS for each unique Kubernetes service described in the ingress resource.

**[4]**: Listeners are created for every port detailed in your ingress resource annotations. When no port is specified, sensible defaults (80 or 443) are used. Certificates may also be attached via annotations.

**[5]**: Rules are created for each path specified in your ingress resource. This ensures traffic to a specific path is routed to the correct Kubernetes Service.

Along with the above, the controller also...

deletes AWS resources when ingress resources are removed from k8s.
modifies AWS resources when ingress resources change in k8s.
assembles a list of existing ingress-related AWS resources on start-up, allowing you to recover if the controller were to be restarted.

Ingress Traffic
~~~~~~~~~~~~~~~

AWS ALB Ingress controller supports two traffic modes: instance mode and ip mode. Users can explicitly specify these traffic modes by declaring the alb.ingress.kubernetes.io/target-type annotation on the Ingress and the service definitions.

- **instance mode**: Ingress traffic starts from the ALB and reaches the `NodePort <NodePort>`_ opened for your service. Traffic is then routed to the pods within the cluster.
- **ip mode**: Ingress traffic starts from the ALB and reaches the pods within the cluster directly. To use this mode, the networking plugin for the Kubernetes cluster must use a secondary IP address on ENI as pod IP, also known as the `AWS CNI plugin for Kubernetes <https://github.com/aws/amazon-vpc-cni-k8s>`_.

Ingress traffic starts at the ALB and reaches the Kubernetes pods directly. CNIs must support directly accessible POD ip via secondary IP addresses on ENI.


Further reading
---------------

1. AWS published a few good technical resources to help you get up to speed on how this works.

  - https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
  - https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html
  - https://aws.amazon.com/blogs/opensource/kubernetes-ingress-aws-alb-ingress-controller/

2. Youtuber `Anton Putra <https://www.youtube.com/channel/UCeLvlbC754U6FyFQbKc0UnQ>`_ created a good `blog article <https://antonputra.com/terraform/how-to-create-eks-cluster-using-terraform/>`_ and `video tutorial <https://www.youtube.com/watch?v=MZyrxzb7yAU>`_ on how to implement an ALB on EKS.
Here's the source code that he uses for both, `https://github.com/antonputra/tutorials/tree/main/lessons/102 <https://github.com/antonputra/tutorials/tree/main/lessons/102>`_.
