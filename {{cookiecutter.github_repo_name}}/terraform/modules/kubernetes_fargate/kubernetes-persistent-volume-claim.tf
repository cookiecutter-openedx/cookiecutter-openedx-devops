#------------------------------------------------------------------------------
# Amazon EBS CSI Driver
#
# for PersistentVolumeClaim by caddy and elasticsearch.
#
# see:
# - https://ntorga.com/deploying-wordpress-with-kubernetes-and-terraform-on-aws/
# - https://medium.com/@muneeburrehman2610/kubernetes-persistent-volume-for-beginners-a13cbe5bdeea
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume
#------------------------------------------------------------------------------
resource "kubernetes_persistent_volume" "caddy" {
  metadata {
    name = "caddy"
  }
  spec {
    capacity = {
      storage = "500M"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      vsphere_volume {
        volume_path = "/home/caddy/vol"
      }
    }
  }
}

#------------------------------------------------------------------------------
# see: https://kubernetes.io/docs/concepts/storage/storage-classes/#aws-ebs
#
#------------------------------------------------------------------------------
resource "kubernetes_storage_class" "ebs-sc" {
  metadata {
    name = "ebs-sc"
  }
  storage_provisioner = "kubernetes.io/aws-ebs"
  parameters = {
    type      = "gp3"
    fsType    = "ext4"
    encrypted = "false"
  }
  reclaim_policy         = "Immediate"
  allow_volume_expansion = true
  tags                   = var.tags
  depends_on = [
    module.eks
  ]
}

#------------------------------------------------------------------------------
# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume_claim
#------------------------------------------------------------------------------
resource "kubernetes_persistent_volume_claim" "caddy" {
  metadata {
    name      = "caddy"
    namespace = var.environment_namespace
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "ebs-sc"
    selector           = {}
    resources {
      requests = {
        storage = "500M"
      }
    }
    volume_name = kubernetes_persistent_volume.caddy.metadata.0.name
  }
  wait_until_bound = true
  depends_on = [
    module.eks
  ]
}
