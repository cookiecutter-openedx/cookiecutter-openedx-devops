AWS Elastic Kubernetes Service (EKS) elastic kubernetes Cluster with Application Load Balancer (ALB)
====================================================================================================

see:
    https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
    https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html

    https://www.youtube.com/watch?v=oYHZ3EPR094&t=1093s
    https://github.com/antonputra/tutorials/tree/main/lessons/038/

    https://www.youtube.com/watch?v=MZyrxzb7yAU
    https://antonputra.com/terraform/how-to-create-eks-cluster-using-terraform/
    https://github.com/antonputra/tutorials/tree/main/lessons/102

How AWS Load Balancer controller works
------------------------------------------

Design
~~~~~~

`AWS Load Balancer Controller Kubernetes Technical documentation <https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/how-it-works/>`_

The following diagram details the AWS components this controller creates. It also demonstrates the route ingress traffic takes from the ALB to the Kubernetes cluster.

.. image:: doc/aws-alb-ingress-controll.png
  :width: 100%
  :alt: How AWS Load Balancer controller works

Ingress Creation
~~~~~~~~~~~~~~~~

**[1]**: The alb ingress controller watches for ingress events from the API server. Ingress events originate from this Terraform code, when you run :bash:`terragrunt apply` or :bash:`terragrunt destroy`. When it finds ingress resources that satisfy its requirements, it begins the creation of AWS resources.

**[2]**: An Application Load Balancer (ALB) is created in AWS for the new ingress resource. This ALB can be internet-facing or internal. You can also specify the subnets it's created in using annotations.

**[3]**: Target Groups are created in AWS for each unique Kubernetes service described in the ingress resource.

**[4]**: Listeners are created for every port detailed in your ingress resource annotations. When no port is specified, sensible defaults (80 or 443) are used. Certificates may also be attached via annotations.

**[5]**: Rules are created for each path specified in your ingress resource. This ensures traffic to a specific path is routed to the correct Kubernetes Service.

Along with the above, the controller also...

deletes AWS components when ingress resources are removed from k8s.
modifies AWS components when ingress resources change in k8s.
assembles a list of existing ingress-related AWS components on start-up, allowing you to recover if the controller were to be restarted.

Ingress Traffic
~~~~~~~~~~~~~~~

AWS Load Balancer controller supports two traffic modes:

Instance mode
IP mode
By default, Instance mode is used, users can explicitly select the mode via :terraform:`alb.ingress.kubernetes.io/target-type` annotation.

**Instance mode**


Ingress traffic starts at the ALB and reaches the Kubernetes nodes through each service's NodePort. This means that services referenced from ingress resources must be exposed by type:NodePort in order to be reached by the ALB.

**IP mode**


Ingress traffic starts at the ALB and reaches the Kubernetes pods directly. CNIs must support directly accessible POD ip via secondary IP addresses on ENI.

Other documentation
-------------------

.. image:: doc/aws-eks_fargate.png
  :width: 100%
  :alt: AWS EKS Fargate Diagram


.. image:: doc/aws-vpc-eks.png
  :width: 100%
  :alt: AWS VPC EKS Diagram


.. image:: doc/node_group-diagram.jpeg
  :width: 100%
  :alt: AWS EKS Node Group Diagram
