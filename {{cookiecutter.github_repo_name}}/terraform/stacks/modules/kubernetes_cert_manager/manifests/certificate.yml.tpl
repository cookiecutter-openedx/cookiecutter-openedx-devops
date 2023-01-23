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
  name: ${services_domain}-tls
  namespace: ${namespace}
spec:
  secretName: ${services_domain}-tls
  issuerRef:
    kind: ClusterIssuer
    name: letsencrypt
  commonName: ${services_domain}
  dnsNames:
    - "${services_domain}"
    - "*.${services_domain}"
