#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com

# date: Mar-2023
#
# usage: implements an ingress for the scorm proxy service for backend
#        storage to AWS S3.
#------------------------------------------------------------------------------
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${environment_namespace}-scorm-proxy-service
  namespace: ${environment_namespace}
  annotations:
    # add sticky sessions
    # ---------------------
    nginx.ingress.kubernetes.io/affinity: "cookie"
    nginx.ingress.kubernetes.io/session-cookie-name: "openedx_sticky_session"
    nginx.ingress.kubernetes.io/session-cookie-expires: "172800"
    nginx.ingress.kubernetes.io/session-cookie-max-age: "172800"

    # scorm proxy service settings
    # -------------------------------------------------------------------------
    # see (best): https://stackoverflow.com/questions/53774386/can-i-point-an-ingress-controller-to-an-external-service-like-aws-s3
    # see (better): https://github.com/kubernetes/ingress-nginx/issues/6165#issuecomment-692684553
    # see: https://github.com/kubernetes/ingress-nginx/issues/4280
    #
    # how it works in Caddy:
    # ----------------------
    #  @scorm_matcher {
    #    path /scorm-proxy/*
    #  }
    #  route @scorm_matcher {
    #    uri /scorm-proxy/* strip_prefix /scorm-proxy
    #    reverse_proxy https://codlp-global-pre-staging-storage.s3.amazonaws.com {
    #      header_up Host codlp-global-pre-staging-storage.s3.amazonaws.com
    #    }
    #  }
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"

spec:
  rules:
  - host: ${environment_domain}
    https:
      paths:
      - path: /scorm-proxy/
        pathType: Prefix
        backend:
          service:
            name: scorm-proxy-service
            port:
              number: 443
  - host: ${studio_subdomain}.${environment_domain}
    https:
      paths:
      - path: /scorm-proxy/
        pathType: Prefix
        backend:
          service:
            name: scorm-proxy-service
            port:
              number: 443
