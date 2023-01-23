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
  namespace: ${cert_manager_namespace}
spec:
  secretName: ${stack_domain}-tls
  issuerRef:
    kind: ClusterIssuer
    name: letsencrypt
  commonName: ${stack_domain}
  dnsNames:
    - "${stack_domain}"
    - "*.${stack_domain}"
