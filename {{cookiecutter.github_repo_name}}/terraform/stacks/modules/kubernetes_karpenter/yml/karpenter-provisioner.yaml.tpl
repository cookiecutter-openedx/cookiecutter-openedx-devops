# -----------------------------------------------------------------------------
# see: https://karpenter.sh/preview/concepts/provisioners/
# -----------------------------------------------------------------------------
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: general-compute
spec:
  ttlSecondsUntilExpired: 2592000
  consolidation:
    enabled: true
  requirements:
    - key: karpenter.sh/capacity-type
      operator: In
      values: ["spot", "on-demand"]
    - key: "karpenter.k8s.aws/instance-cpu"
      operator: In
      values: ["2", "4", "8"]
    - key: kubernetes.io/arch
      operator: In
      values: ["amd64"]
  limits:
    resources:
      cpu: 400
      memory: 1600Gi
  providerRef:
    name: default
