#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: setup nginx for EKS load balancer.
#        see https://cert-manager.io/docs/
#------------------------------------------------------------------------------
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${environment_namespace}
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
  - host: ${environment_domain}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: lms
            port:
              number: 8000
  - host: "preview.${environment_domain}"
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: lms
            port:
              number: 8000
  - host: ${studio_subdomain}.${environment_domain}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: cms
            port:
              number: 8000
  - host: discovery.${environment_domain}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: discovery
            port:
              number: 8000
