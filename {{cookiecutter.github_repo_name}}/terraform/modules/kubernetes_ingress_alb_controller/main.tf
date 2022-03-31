#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: Deploy the `official` Kubernetes ingress ALB controller
#        via its Helm chart.
#
# Setup instructions:
# -------------------
# - https://aws.github.io/kubernetes-charts/aws-load-balancer-controller
# - https://github.com/aws/kubernetes-charts/tree/v0.0.82/stable/aws-load-balancer-controller
# - https://aws.amazon.com/premiumsupport/knowledge-center/kubernetes-alb-ingress-controller-fargate/
#
# technical documentation:
# - https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller
# - https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/
# - https://github.com/aws/kubernetes-charts/tree/master/stable/aws-load-balancer-controller
# - https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/
#
#
# trouble shooting:
# ------------------
# Error: Failed to create Ingress 'ingress-alb-controller/nginx-lb' because:
#        Internal error occurred: failed calling webhook "vingress.elbv2.k8s.aws":
#        Post "https://aws-load-balancer-webhook-service.ingress-alb-controller.svc:443/validate-networking-v1-ingress?timeout=10s": context deadline exceeded
#
# Resolution: during EKS creation, have open to port ??? (9443 ???) in EKS node shared security group
# - https://github.com/kubernetes-sigs/aws-load-balancer-controller/issues/2462
#------------------------------------------------------------------------------

locals {
  k8s_namespace = "kube-system"
  resource_name = "aws-load-balancer-controller"
}

#------------------------------------------------------------------------------
# https://aws.amazon.com/premiumsupport/knowledge-center/kubernetes-alb-ingress-controller-fargate/
#
# 2. To allow the cluster to use AWS Identity and Access Management (IAM) for
#    service accounts, run the following command:
#    eksctl utils associate-iam-oidc-provider --cluster var.environment_namespace --approve
#------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}
data "aws_iam_policy_document" "eks_oidc_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values = [
        "system:serviceaccount:${local.k8s_namespace}:aws-load-balancer-controller"
      ]
    }
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}"
      ]
      type = "Federated"
    }
  }
}

resource "aws_iam_role" "this" {
  name                  = "${var.environment_namespace}-aws-load-balancer-controller"
  description           = "Permissions required by the Kubernetes AWS Load Balancer controller to do its job."
  tags                  = var.tags
  force_detach_policies = true
  assume_role_policy    = data.aws_iam_policy_document.eks_oidc_assume_role.json
}

#------------------------------------------------------------------------------
# https://aws.amazon.com/premiumsupport/knowledge-center/kubernetes-alb-ingress-controller-fargate/
#
# 3. To download an IAM policy that allows the AWS Load Balancer Controller to
#    make calls to AWS APIs on your behalf, run the following command:
#    curl -o ./json/iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.2.0/docs/install/iam_policy.json
#
# 4. To create an IAM policy using the policy that you downloaded in step 3,
#    run the following command:
#    aws iam create-policy \
#       --policy-name AWSLoadBalancerControllerIAMPolicy \
#       --policy-document file://iam_policy.json
#
# need to review these alternatives
# https://docs.aws.amazon.com/elasticloadbalancing/latest/userguide/load-balancer-authentication-access-control.html
#------------------------------------------------------------------------------
resource "aws_iam_policy" "this" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "Allows the AWS Load Balancer Controller to make calls to AWS APIs on your behalf."
  policy      = file("${path.module}/json/iam-policy.json")
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = aws_iam_policy.this.arn
  role       = aws_iam_role.this.name
}

#------------------------------------------------------------------------------
# https://aws.amazon.com/premiumsupport/knowledge-center/kubernetes-alb-ingress-controller-fargate/
#
# 5. To create a service account named aws-load-balancer-controller in the
#    kube-system namespace for the AWS Load Balancer Controller,
#    run the following command:
#     eksctl create iamserviceaccount \
#         --cluster=YOUR_CLUSTER_NAME \
#         --namespace=kube-system \
#         --name=aws-load-balancer-controller \
#         --attach-policy-arn=arn:aws:iam::<AWS_ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
#         --override-existing-serviceaccounts \
#         --approve
#------------------------------------------------------------------------------
resource "kubernetes_service_account" "this" {
  automount_service_account_token = true
  metadata {
    name      = local.resource_name
    namespace = local.k8s_namespace // note that example uses `kube-system`
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.this.arn
    }
    labels = {
      "app.kubernetes.io/name"       = local.resource_name
      "app.kubernetes.io/component"  = "controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  depends_on = [data.aws_eks_cluster.cluster]
}

resource "kubernetes_cluster_role_binding" "this" {
  metadata {
    name = local.resource_name

    labels = {
      "app.kubernetes.io/name"       = local.resource_name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.this.metadata[0].name
  }

  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.this.metadata[0].name
    namespace = kubernetes_service_account.this.metadata[0].namespace
  }

  depends_on = [kubernetes_service_account.this]
}
resource "kubernetes_cluster_role" "this" {
  metadata {
    name = local.resource_name

    labels = {
      "app.kubernetes.io/name"       = local.resource_name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  rule {
    api_groups = [
      "",
      "extensions",
    ]

    resources = [
      "configmaps",
      "endpoints",
      "events",
      "ingresses",
      "ingresses/status",
      "services",
    ]

    verbs = [
      "create",
      "get",
      "list",
      "update",
      "watch",
      "patch",
    ]
  }

  rule {
    api_groups = [
      "",
      "extensions",
    ]

    resources = [
      "nodes",
      "pods",
      "secrets",
      "services",
      "namespaces",
    ]

    verbs = [
      "get",
      "list",
      "watch",
    ]
  }
  depends_on = [data.aws_eks_cluster.cluster]
}


#------------------------------------------------------------------------------
# https://aws.amazon.com/premiumsupport/knowledge-center/kubernetes-alb-ingress-controller-fargate/
#
# 6. To verify that the new service role was created, run the following command:
#    eksctl get iamserviceaccount --cluster YOUR_CLUSTER_NAME --name aws-load-balancer-controller --namespace kube-system
#
#    or
#
#    kubectl get serviceaccount aws-load-balancer-controller --namespace ingress-alb-controller
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# https://aws.amazon.com/premiumsupport/knowledge-center/kubernetes-alb-ingress-controller-fargate/
#
# Install the AWS Load Balancer Controller using Helm:
#
#    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
#          --set clusterName=YOUR_CLUSTER_NAME \
#          --set serviceAccount.create=false \
#          --set region=YOUR_REGION_CODE \
#          --set vpcId=<VPC_ID> \
#          --set serviceAccount.name=aws-load-balancer-controller \
#          -n kube-system
#
#------------------------------------------------------------------------------
resource "helm_release" "alb_controller" {
  name       = local.resource_name
  repository = "https://aws.github.io/kubernetes-charts"
  chart      = "aws-load-balancer-controller"
  version    = "{{ cookiecutter.terraform_helm_alb_controller_chart_version }}"
  namespace  = local.k8s_namespace
  atomic     = true
  timeout    = 900
  depends_on = [
    data.aws_eks_cluster.cluster,
    kubernetes_service_account.this
  ]

  set {
    name  = "clusterName"
    value = var.environment_namespace
  }
  set {
    name  = "serviceAccount.create"
    value = false
  }
  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.this.metadata[0].name
  }
  set {
    name  = "region"
    value = var.aws_region
  }
  set {
    name  = "vpcId"
    value = var.vpc_id
  }

}
