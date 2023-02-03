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
  name: ${services_subdomain}-tls
  namespace: ${namespace}
spec:
  secretName: ${services_subdomain}-tls
  issuerRef:
    kind: ClusterIssuer
    name: ${services_subdomain}
  commonName: ${services_subdomain}
  dnsNames:
    - "${services_subdomain}"
    - "*.${services_subdomain}"
