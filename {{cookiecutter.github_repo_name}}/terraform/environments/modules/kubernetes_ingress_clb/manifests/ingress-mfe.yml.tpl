#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com

# date: Jul-2023
#
# usage: add an ingress for learning MFE traffic
#------------------------------------------------------------------------------
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${environment_namespace}-mfe
  namespace: ${environment_namespace}
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
    cert-manager.io/cluster-issuer: ${environment_domain}

    # mcdaniel mar-2023
    # force ssl redirect
    # ---------------------
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
spec:
  tls:
  - hosts:
    - "${environment_domain}"
    - "*.${environment_domain}"
    secretName: ${environment_domain}-tls
  rules:
  - host: apps.${environment_domain}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: mfe
            port:
              number: 8002
