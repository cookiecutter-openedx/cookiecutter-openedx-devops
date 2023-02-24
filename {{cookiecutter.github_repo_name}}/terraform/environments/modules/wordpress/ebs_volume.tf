#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: create a detachable EBS volume to be used as the PVC for the Wordpress pod.
#
# Problems we're trying to solve: the Bitnami Wordpress chart provides
# dynamic PVC and volume management by default, but there are shortcomings:
#  1. the EBS drive volume gets destroyed whenever we run Terraform destroy on
#     a Wordpress site, which is usually **not** what we want.
#
#  2. the EBS volumes are generically named and tagged. we'd prefer to see
#     identifying information that helps us understand which EBS volume belongs
#     to which Wordpress site.
#
#  3. The Bitnami charts lacks granular control over the design attributes of the
#     EBS volume, the PV and the PVC. We want to maintain the potential to fine
#     tune these in the future.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
#                        KUBERNETES RESOURCES
#------------------------------------------------------------------------------
resource "kubernetes_persistent_volume_claim" "wordpress" {
  metadata {
    name      = local.wordpressDomain
    namespace = local.wordpressNamespace
    labels = {
      "ebs_volume_id" = "${aws_ebs_volume.wordpress.id}"
      "name"          = "${local.wordpressDomain}"
      "namespace"     = "${local.wordpressNamespace}"
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "gp2"
    resources {
      requests = {
        storage = "${local.persistenceSize / 2}Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.wordpress.metadata.0.name
  }

  depends_on = [
    kubernetes_persistent_volume.wordpress
  ]
}

resource "kubernetes_persistent_volume" "wordpress" {
  metadata {
    name      = local.wordpressDomain
    labels = {
      "topology.kubernetes.io/region" = "${var.aws_region}"
      "topology.kubernetes.io/zone" = "${aws_ebs_volume.wordpress.availability_zone}"
      "ebs_volume_id" = "${aws_ebs_volume.wordpress.id}"
      "name"      = "${local.wordpressDomain}"
      "namespace" = "${local.wordpressNamespace}"
    }
    annotations = {
    }
  }

  spec {
    capacity = {
        storage = "${local.persistenceSize}Gi"
    }
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "gp2"
    persistent_volume_source {
      aws_elastic_block_store {
        volume_id = aws_ebs_volume.wordpress.id
        fs_type = "ext4"
      }
    }
    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key = "topology.kubernetes.io/zone"
            operator = "In"
            values = ["${aws_ebs_volume.wordpress.availability_zone}"]
          }
          match_expressions {
            key = "topology.kubernetes.io/region"
            operator = "In"
            values = ["${var.aws_region}"]
          }
        }
      }
    }
  }

  depends_on = [
    aws_ebs_volume.wordpress
  ]
}

# create a detachable EBS volume for the wordpress databases
#------------------------------------------------------------------------------
#                     AWS ELASTIC BLOCK STORE RESOURCES
#------------------------------------------------------------------------------
resource "aws_ebs_volume" "wordpress" {
  availability_zone = data.aws_subnet.private_subnet.availability_zone
  size              = local.persistenceSize
  tags              = var.tags

  # local.ebsVolumePreventDestroy defaults to 'Y'
  # for anything other than an upper case 'N' we'll assume that
  # we should not destroy this resource.
  lifecycle {
    prevent_destroy = false
  }

  depends_on = [
    data.aws_subnet.private_subnet
  ]
}


#------------------------------------------------------------------------------
#                        SUPPORTING RESOURCES
#------------------------------------------------------------------------------

data "aws_subnet" "private_subnet" {
  id = var.subnet_ids[random_integer.subnet_id.result]
}

# randomize the choice of subnet. Each of the
# possible subnets corresponds to the AWS availability
# zones in the data center. Most data center have three
# availability zones, but some like us-east-1 have more than
# three.
resource "random_integer" "subnet_id" {
  min = 0
  max = length(var.subnet_ids) - 1
}
