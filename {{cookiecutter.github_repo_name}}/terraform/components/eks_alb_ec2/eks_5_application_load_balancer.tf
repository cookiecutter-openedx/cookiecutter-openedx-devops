#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: create an Application Load Balancer (ALB)
#
# note: references to the "Fargate pod" in AWS documentation are in fact,
#       this ALB.
#
# see:
# - https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/ingress/annotations/
# - https://aws.amazon.com/premiumsupport/knowledge-center/eks-alb-ingress-controller-fargate/
#------------------------------------------------------------------------------

# This becomes arn:aws:iam::320713933456:policy/ALBIngressControllerIAMPolicy
resource "aws_iam_policy" "ALB-policy" {
  name = "ALBIngressControllerIAMPolicy"

  # note: this IAM policy json comes directly from the AWS support web site.
  # see https://aws.amazon.com/premiumsupport/knowledge-center/eks-alb-ingress-controller-fargate/
  #
  # source:
  # $ curl -o iam_policy_alb.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.2.0/docs/install/iam_policy.json
  policy = file("./json/iam_policy_alb.json")
}

resource "aws_iam_role" "eks_alb_ingress_controller" {
  name                  = "eks-alb-ingress-controller"
  description           = "Permissions required by the Kubernetes AWS ALB Ingress controller to do its job."
  force_detach_policies = true
  assume_role_policy    = <<ROLE
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub": "system:serviceaccount:kube-system:alb-ingress-controller"
        }
      }
    }
  ]
}
ROLE
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

resource "kubernetes_service_account" "ingress" {
  automount_service_account_token = true
  metadata {
    name      = "alb-ingress-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"       = "alb-ingress-controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks_alb_ingress_controller.arn
    }
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


resource "kubernetes_deployment" "ingress" {
  metadata {
    name      = "alb-ingress-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"       = "alb-ingress-controller"
      "app.kubernetes.io/version"    = "v1.1.6"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "alb-ingress-controller"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"    = "alb-ingress-controller"
          "app.kubernetes.io/version" = "v1.1.6"
        }
      }

      spec {
        dns_policy                       = "ClusterFirst"
        restart_policy                   = "Always"
        service_account_name             = kubernetes_service_account.ingress.metadata[0].name
        termination_grace_period_seconds = 60

        container {
          name              = "alb-ingress-controller"
          image             = "docker.io/amazon/aws-alb-ingress-controller:v1.1.6"
          image_pull_policy = "Always"

          args = [
            "--ingress-class=alb",
            "--cluster-name=${var.environment_namespace}",
            "--aws-vpc-id=${var.vpc_id}",
            "--aws-region=${var.aws_region}",
            "--aws-max-retries=10",
          ]
          volume_mount {
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
            name       = kubernetes_service_account.ingress.default_secret_name
            read_only  = true
          }
        }
        volume {
          name = kubernetes_service_account.ingress.default_secret_name

          secret {
            secret_name = kubernetes_service_account.ingress.default_secret_name
          }
        }
      }
    }
  }

  depends_on = [kubernetes_cluster_role_binding.ingress]
}
