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
# example: https://apps.${environment_domain}/api/mfe_config/v1?mfe=authn
#------------------------------------------------------------------------------
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${environment_namespace}-mfe-config
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
    # ----------------------
    # We need to specify the host header, otherwise it will be rejected with 400
    # from the lms.
    # ----------------------
    nginx.ingress.kubernetes.io/upstream-vhost: ${environment_domain}

    # to eliminate the trailing slash without loosing the param
    # see: https://github.com/kubernetes/ingress-nginx/blob/main/docs/examples/rewrite/README.md
    # ----------------------
    nginx.ingress.kubernetes.io/rewrite-target: /api/mfe_config/v1$2

    # mcdaniel mar-2023
    # add sticky sessions
    # ---------------------
    nginx.ingress.kubernetes.io/affinity: "cookie"
    nginx.ingress.kubernetes.io/session-cookie-name: "openedx_sticky_session"
    nginx.ingress.kubernetes.io/session-cookie-expires: "172800"
    nginx.ingress.kubernetes.io/session-cookie-max-age: "172800"

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
      - path: /api/mfe_config/v1(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: lms
            port:
              number: 8000
