#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: setup SSL certs for EKS load balancer worker node instances.
#        see https://cert-manager.io/docs/
#------------------------------------------------------------------------------
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${environment_domain}
spec:
  secretName: ${environment_domain}-tls
  issuerRef:
    kind: ClusterIssuer
    name: ${environment_domain}
  commonName: ${environment_domain}
  dnsNames:
    - "*.${environment_domain}"
