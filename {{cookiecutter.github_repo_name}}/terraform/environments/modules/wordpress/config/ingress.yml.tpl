#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com

# date: Feb-2023
#
# usage: Wordpress ingress deployed to common nginx controller
#------------------------------------------------------------------------------
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${name}
  namespace: ${namespace}
  annotations:
    # mcdaniel
    # https://www.cyberciti.biz/faq/nginx-upstream-sent-too-big-header-while-reading-response-header-from-upstream/
    # to fix "[error] 199#199: *15739 upstream sent too big header while reading response header from upstream"
    # ---------------------
    nginx.ingress.kubernetes.io/proxy-busy-buffers-size: "512k"
    nginx.ingress.kubernetes.io/proxy-buffers: "4 512k"
    nginx.ingress.kubernetes.io/proxy-buffer-size: "256k"
    # ---------------------
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: ${cluster_issuer}
spec:
  tls:
  - hosts:
    - "${root_domain}"
    - "*.${root_domain}"
    secretName: ${root_domain}-tls
  rules:
  - host: ${domain}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: wordpress
            port:
              number: 80
