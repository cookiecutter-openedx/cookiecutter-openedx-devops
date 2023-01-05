global:
  podSecurityPolicy:
    enabled: true
    useAppArmor: true
image:
  tag: v1.8.0
webhook:
  image:
    tag: v1.8.0
prometheus:
  enabled: false
installCRDs: true
extraArgs:
  - --issuer-ambient-credentials
serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: ${role_arn}
  name: cert-manager
  namespace: ${environment_namespace}
# the securityContext is required, so the pod can access files required to assume the IAM role
securityContext:
  # -------------------------------------------------------------------------------
  # mcdaniel dec-2022: see https://github.com/cert-manager/cert-manager/issues/5549
  #enabled: true
  # -------------------------------------------------------------------------------
  fsGroup: 1001
