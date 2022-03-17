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

################################################################################
# Supporting Resources
################################################################################

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
  assume_role_policy    = file("./json/iam_policy_alb_controller.json")
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
    labels = {
      "app.kubernetes.io/name"       = "alb-ingress-controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks_alb_ingress_controller.arn
    }
  }
}