#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com

# date: Jan-2023
#
# usage: open-release olive.1 and newer include the url endpoint /api/mfe_config/v1
#        that is implemented in edx-platform/lms/djangoapps/mfe_config_api.
#
#        we need to add a special ingress, just for this endpoint.
#        note that this ingress requires an additional annotation to set the
#        Host header in the request to the hostname of the lms.
#
# example: https://apps.${domain}/api/mfe_config/v1?mfe=authn
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
    - "${domain}"
    secretName: ${domain}-tls
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
              number: 8080
