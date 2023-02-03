#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: setup SSL certs for EKS load balancer worker node instances.
#        see https://cert-manager.io/docs/
#------------------------------------------------------------------------------
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: {{ cookiecutter.global_services_subdomain }}.{{ cookiecutter.global_root_domain }}
  namespace: ${namespace}
spec:
  acme:
    email: no-reply@${root_domain}
    privateKeySecretRef:
      name: {{ cookiecutter.global_services_subdomain }}.{{ cookiecutter.global_root_domain }}
    server: https://acme-v02.api.letsencrypt.org/directory
    solvers:
      - dns01:
          # hosted Zone ID for the admin domain.
          route53:
            region: ${aws_region}
            hostedZoneID: ${hosted_zone_id}
