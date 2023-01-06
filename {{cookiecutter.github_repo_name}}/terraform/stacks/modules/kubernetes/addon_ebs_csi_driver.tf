#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Dec-2022
#
# Create the Amazon EBS CSI driver IAM role for service accounts
# https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html
#
# Note:  in late december 2022 the AWS EKS EBS CSI Add-on suddenly began
#        inheriting its IAM role from the karpenter node group rather than using
#        the role that is explicitly created and assigned here. no idea why.
#        As a workaround, i'm also adding the AmazonEBSCSIDriverPolicy policy to the
#        karpenter node group, which is assigned inside the eks module in main.tf.
#------------------------------------------------------------------------------

data "aws_iam_policy" "AmazonEBSCSIDriverPolicy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# 2. Create the IAM role.
resource "aws_iam_role" "AmazonEKS_EBS_CSI_DriverRole" {
  name = "AmazonEKS_EBS_CSI_DriverRole"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${var.account_id}:oidc-provider/${module.eks.oidc_provider}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${module.eks.oidc_provider}:aud" : "sts.amazonaws.com",
            "${module.eks.oidc_provider}:sub" : "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
  tags = var.tags
}

# 3. Attach the required AWS managed policy to the role
resource "aws_iam_role_policy_attachment" "aws_ebs_csi_driver" {
  role       = aws_iam_role.AmazonEKS_EBS_CSI_DriverRole.name
  policy_arn = data.aws_iam_policy.AmazonEBSCSIDriverPolicy.arn
}

# 5. Annotate the ebs-csi-controller-sa Kubernetes service account with the ARN of the IAM role
# 6. Restart the ebs-csi-controller deployment for the annotation to take effect
resource "null_resource" "annotate-ebs-csi-controller" {

  provisioner "local-exec" {
    command = <<-EOT
      kubectl annotate serviceaccount ebs-csi-controller-sa -n kube-system eks.amazonaws.com/role-arn=arn:aws:iam::${var.account_id}:role/${aws_iam_role.AmazonEKS_EBS_CSI_DriverRole.name}
      kubectl rollout restart deployment ebs-csi-controller -n kube-system
    EOT
  }

  depends_on = [
    module.eks
  ]
}
