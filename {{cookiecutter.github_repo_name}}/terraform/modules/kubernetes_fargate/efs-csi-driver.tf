#------------------------------------------------------------------------------
# Amazon EFS CSI Driver
#
# for PersistentVolumeClaim by caddy and elasticsearch. For static provisioning,
# AWS EFS file system needs to be created manually on AWS first.
# After that it can be mounted inside a container as a volume using the driver.
#
#
# see: https://github.com/kubernetes-sigs/aws-efs-csi-driver
#
# helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/
# helm repo update
# helm upgrade --install aws-efs-csi-driver --namespace kube-system aws-efs-csi-driver/aws-efs-csi-driver
#
#------------------------------------------------------------------------------

resource "helm_release" "aws_efs_csi_driver" {
  name       = local.resource_name
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  chart      = "aws-efs-csi-driver"
  version    = "{{ cookiecutter.terraform_helm_aws_efs_csi_driver_version }}"
  namespace  = "kube-system"
  atomic     = true
  timeout    = 900
  depends_on = [
    data.aws_eks_cluster.cluster
  ]
}
