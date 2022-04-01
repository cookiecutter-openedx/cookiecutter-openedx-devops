#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: create a kubernetes ingress in the form of an AWS Application Load
#        Balancer (ALB).
#
#------------------------------------------------------------------------------
locals {
  namespace = "openedx"
}

data "aws_acm_certificate" "issued" {
  domain   = var.environment_domain
  statuses = ["ISSUED"]
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "sg_alb" {
  name_prefix = "${var.environment_namespace}-alb"
  description = "Public-facing ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "public http from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "public https from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags
}

#------------------------------------------------------------------------------
# Amazon EKS pods running on AWS Fargate now support custom security groups
# https://aws.amazon.com/about-aws/whats-new/2021/06/amazon-eks-pods-running-aws-fargate-support-custom-security-groups/
#
# https://github.com/weaveworks/kubernetesctl/issues/1640
# For exposing an HTTP service, it so far only supports ALB with IP mode and you should specify your service as ClusterIP.
#------------------------------------------------------------------------------
resource "kubernetes_service" "nginx" {
  metadata {
    name      = "ingress-service"
    namespace = local.namespace
    annotations = {
      "alb.ingress.kubernetes.io/target-type" = "ip"
    }
  }
  spec {
    type = "ClusterIP"
    #selector = {
    #  App = kubernetes_deployment.nginx.spec.0.template.0.metadata[0].labels.App
    #}
    selector = {
      App = "nginx"
    }
    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

  }
  #depends_on = [kubernetes_deployment.nginx]
}


#------------------------------------------------------------------------------
# This works with the EKS ALB controller (see main.tf) to create and configure
# an Application Load Balancer (ALB).
#
# metadata:
#  - the ALB resource identifiers in both EKS as well as the AWS console.
#  - the label "app" = "nginx" might not be necessary
#
# annotations: the configuration options for the ALB.
#
# spec:
#  - tls might not need to be there since we're annotating alb.ingress.kubernetes.io/certificate-arn
#  - backend defines the target group nodes
#  - rule defines the ALB routing configuration
#------------------------------------------------------------------------------
resource "kubernetes_ingress" "alb" {
  wait_for_load_balancer = true
  metadata {
    name      = "ingress-alb"
    namespace = local.namespace
    labels = {
      "app" = "nginx"
    }
    # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/ingress/annotations/
    # https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/
    annotations = {
      "kubernetes.io/ingress.class"                            = "alb"
      "alb.ingress.kubernetes.io/scheme"                       = "internet-facing"
      "alb.ingress.kubernetes.io/load-balancer-name"           = var.environment_namespace
      "alb.ingress.kubernetes.io/certificate-arn"              = data.aws_acm_certificate.issued.arn
      "alb.ingress.kubernetes.io/ip-address-type"              = "ipv4"
      "alb.ingress.kubernetes.io/security-groups"              = aws_security_group.sg_alb.id,
      "alb.ingress.kubernetes.io/ssl-redirect"                 = "443"
      "alb.ingress.kubernetes.io/backend-protocol"             = "HTTP"
      "alb.ingress.kubernetes.io/healthcheck-port"             = "80"
      "alb.ingress.kubernetes.io/healthcheck-path"             = "/"
      "alb.ingress.kubernetes.io/healthcheck-interval-seconds" = "15"
      "alb.ingress.kubernetes.io/healthcheck-timeout-seconds"  = "5"
      "alb.ingress.kubernetes.io/healthy-threshold-count"      = "2"
      "alb.ingress.kubernetes.io/unhealthy-threshold-count"    = "2"
      "alb.ingress.kubernetes.io/success-codes"                = "200-399"
      "alb.ingress.kubernetes.io/target-node-labels"           = "label1=nginx"
      "alb.ingress.kubernetes.io/listen-ports"                 = jsonencode([{ "HTTP" : 80 }, { "HTTPS" : 443 }])
      "alb.ingress.kubernetes.io/tags"                         = "Environment=${var.environment_namespace}"
    }
  }

  spec {
    tls {
      hosts = [
        "${var.environment_domain}"
      ]
    }
    backend {
      service_name = kubernetes_service.nginx.metadata.0.name
      service_port = 80
    }
    rule {
      http {
        path {
          path = "/*"
          backend {
            service_name = kubernetes_service.nginx.metadata.0.name
            service_port = 80
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.alb_controller,
    aws_security_group.sg_alb,
    kubernetes_deployment.nginx,
    kubernetes_service.nginx
  ]
}
