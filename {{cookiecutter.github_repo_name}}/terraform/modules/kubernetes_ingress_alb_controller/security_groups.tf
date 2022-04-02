#------------------------------------------------------------------------------
# This security group is created automatically by the EKS and is one of three
# security groups associated with the cluster. The terraform module
# terraform-aws-modules/eks/aws, above, provides hooks for the other two, but
# does not provide us with a way to modify this one.
#
# We have to rely on the kubernetes-managed resource tags to identify it.
#
# Also, note that this security group is identifiable in the AWS Console
# with the following description: "EKS created security group applied to ENI that
#     is attached to EKS Control Plane master nodes, as well as any managed
#     workloads."
#------------------------------------------------------------------------------
data "aws_security_group" "eks" {
  tags = merge(
    {
      "kubernetes.io/cluster/${var.environment_namespace}" = "owned"
    },
    {
      "aws:eks:cluster-name" = "${var.environment_namespace}"
    },
  )

}

# we need this so that we can pass the cidr of the vpc
# to the security group rule below.
data "aws_vpc" "environment" {

  filter {
    name   = "tag-value"
    values = ["${var.environment_namespace}"]
  }
  filter {
    name   = "tag-key"
    values = ["Name"]
  }

}

#------------------------------------------------------------------------------
# mcdaniel mar-2022
# this is needed so that Fargate nodes can receive traffic from resources
# inside the VPC; namely, the ALB.
#------------------------------------------------------------------------------
resource "aws_security_group_rule" "nginx" {
  description       = "http port 80 from inside the VPC"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.environment.cidr_block]
  security_group_id = data.aws_security_group.eks.id
}
