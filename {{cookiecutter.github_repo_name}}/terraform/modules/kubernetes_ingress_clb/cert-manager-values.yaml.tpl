global:
  podSecurityPolicy:
    enabled: true
    useAppArmor: true
image:
  tag: v1.4.0
webhook:
  image:
    tag: v1.4.0
prometheus:
  enabled: false
installCRDs: true
extraArgs:
  - --issuer-ambient-credentials
serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: ${role_arn}
# the securityContext is required, so the pod can access files required to assume the IAM role
securityContext:
  enabled: true
  fsGroup: 1001
