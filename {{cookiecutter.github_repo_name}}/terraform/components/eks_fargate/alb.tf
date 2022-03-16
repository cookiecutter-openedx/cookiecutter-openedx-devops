#------------------------------------------------------------------------------ 
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: create an Application Load Balancer (ALB)
#
# see:
# - https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/ingress/annotations/
# - https://aws.amazon.com/premiumsupport/knowledge-center/eks-alb-ingress-controller-fargate/
#------------------------------------------------------------------------------ 

# see eks_fargate/acm.tf for creation of this certificate
data "aws_acm_certificate" "environment_domain" {
  domain   = var.environment_domain
  statuses = ["ISSUED"]
  provider = "aws.environment_region"
}


################################################################################
# Supporting Resources
################################################################################
resource "aws_iam_policy" "ALB-policy" {
  name   = "ALBIngressControllerIAMPolicy"
  policy = file("./iam/iam_policy_alb.json")
}

resource "aws_iam_role" "eks_alb_ingress_controller" {
  name        = "eks-alb-ingress-controller"
  description = "Permissions required by the Kubernetes AWS ALB Ingress controller to do its job."
  force_detach_policies = true
  assume_role_policy = file(".iam/iam_policy_alb_controller.json")
}

resource "aws_iam_role_policy_attachment" "ALB-policy_attachment" {
  policy_arn = aws_iam_policy.ALB-policy.arn
  role       = aws_iam_role.eks_alb_ingress_controller.name
}

resource "kubernetes_cluster_role" "ingress" {
  metadata {
    name = "alb-ingress-controller"
    labels = {
      "app.kubernetes.io/name"       = "alb-ingress-controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  rule {
    api_groups = ["", "extensions"]
    resources  = ["configmaps", "endpoints", "events", "ingresses", "ingresses/status", "services"]
    verbs      = ["create", "get", "list", "update", "watch", "patch"]
  }

  rule {
    api_groups = ["", "extensions"]
    resources  = ["nodes", "pods", "secrets", "services", "namespaces"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "ingress" {
  metadata {
    name = "alb-ingress-controller"
    labels = {
      "app.kubernetes.io/name"       = "alb-ingress-controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.ingress.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.ingress.metadata[0].name
    namespace = kubernetes_service_account.ingress.metadata[0].namespace
  }

  depends_on = [kubernetes_cluster_role.ingress]
}

resource "kubernetes_service_account" "ingress" {
  automount_service_account_token = true
  metadata {
    name      = "alb-ingress-controller"
    namespace = "kube-system"
    labels    = {
      "app.kubernetes.io/name"       = "alb-ingress-controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks_alb_ingress_controller.arn
    }
  }
}

################################################################################
# Ingress for Application Load Balancer
#
# - assuming that we do not need to explicitely a create a security group
#         "alb.ingress.kubernetes.io/security-groups" = "SET ME PLEEASE"
#
# - TO DO: investigate these
#         "alb.ingress.kubernetes.io/load-balancer-attributes"
#         "alb.ingress.kubernetes.io/auth-session-cookie"
#         "alb.ingress.kubernetes.io/group.name"
################################################################################

resource "kubernetes_ingress" "app" {
  metadata {
    name      = "owncloud-lb"
    namespace = var.fargate_namespace
    annotations = {
      "kubernetes.io/ingress.class"                         = "alb"
      "alb.ingress.kubernetes.io/scheme"                    = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"               = "ip"
      "alb.ingress.kubernetes.io/ip-address-type"           = "ipv4"

      "alb.ingress.kubernetes.io/listen-ports"              = jsonencode([{"HTTP": 80}, {"HTTPS": 443}, {"HTTP": 8080}, {"HTTPS": 8443}])
      "alb.ingress.kubernetes.io/ssl-redirect"              = 443
      "alb.ingress.kubernetes.io/certificate-arn"           = data.aws_acm_certificate.environment_domain.arn
      "alb.ingress.kubernetes.io/backend-protocol"          = "HTTP"
      "alb.ingress.kubernetes.io/success-codes"             = "'200' | '301'"
      "alb.ingress.kubernetes.io/auth-session-timeout"      = 604800

      "alb.ingress.kubernetes.io/load-balancer-name"        = "${var.environment_namespace}"
      "alb.ingress.kubernetes.io/subnets"                   = "${var.subnet_ids}"

    }
    labels = {
        "app" = "owncloud"
    }
  }

  spec {
      backend {
        service_name = "owncloud-service"
        service_port = 80
      }
    rule {
      http {
        path {
          path = "/*"
          backend {
            service_name = kubernetes_service.app.metadata.0.name
            service_port = 80
          }
        }
      }
    }
  }
  
  depends_on = [
    kubernetes_service.app,
    data.aws_acm_certificate.environment_domain
  ]

  tags = var.tags
}

