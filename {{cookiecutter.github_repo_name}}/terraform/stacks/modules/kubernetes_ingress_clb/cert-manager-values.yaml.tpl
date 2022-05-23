global:
  podSecurityPolicy:
    enabled: true
    useAppArmor: true
image:
  tag: {{ cookiecutter.terraform_helm_cert_manager_image_tag }}
webhook:
  image:
    tag: {{ cookiecutter.terraform_helm_cert_manager_image_tag }}
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
