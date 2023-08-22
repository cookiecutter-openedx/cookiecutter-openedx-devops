apiVersion: karpenter.k8s.aws/v1alpha1
kind: AWSNodeTemplate
metadata:
  name: default
spec:
  subnetSelector:
    karpenter.sh/discovery: ${stack_namespace}
  securityGroupSelector:
    karpenter.sh/discovery: ${stack_namespace}
  tags:
    karpenter.sh/discovery: ${stack_namespace}
  blockDeviceMappings:
    - deviceName: /dev/xvda
      ebs:
        volumeType: gp3
        volumeSize: 50Gi
        deleteOnTermination: true
