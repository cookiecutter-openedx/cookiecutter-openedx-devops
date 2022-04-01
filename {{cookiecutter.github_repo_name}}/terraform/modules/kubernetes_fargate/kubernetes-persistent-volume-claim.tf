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
# see: https://ntorga.com/deploying-wordpress-with-kubernetes-and-terraform-on-aws/
#------------------------------------------------------------------------------


resource "kubernetes_persistent_volume_claim" "caddy" {
  metadata {
    name = "caddy-pvc"
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "efs-sc"
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
  depends_on = [
    module.eks
  ]
}

resource "kubernetes_storage_class" "efs-sc" {
  metadata {
    name = "efs-sc"
  }
  storage_provisioner = "efs.csi.aws.com"
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = "caddy"
    directoryPerms   = 700
  }
  depends_on = [
    module.eks
  ]
}
