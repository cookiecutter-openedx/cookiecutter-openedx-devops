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
  name: ${namespace}
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
    cert-manager.io/cluster-issuer: "letsencrypt"
spec:
  tls:
  - hosts:
    - "${environment_domain}"
    - "*.${environment_domain}"
    secretName: "${environment_domain}-tls"
  rules:
  - host: "${environment_domain}"
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: lms
            port:
              number: 8000
  - host: "{{ cookiecutter.environment_studio_subdomain }}.${environment_domain}"
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: cms
            port:
              number: 8000
  - host: "apps.${environment_domain}"
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: mfe
            port:
              number: 8002

  - host: "subscriptions.${environment_domain}"
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: license-manager
            port:
              number: 8000
