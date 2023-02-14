apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: "cost-analyzer"
  namespace: ${subdomain}
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: ${services_domain}
spec:
  tls:
  - hosts:
    - "${subdomain}.${services_domain}"
    secretName: "${subdomain}.${services_domain}-tls"
  rules:
  - host: ${subdomain}.${services_domain}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: cost-analyzer-cost-analyzer
            port:
              number: 9090
