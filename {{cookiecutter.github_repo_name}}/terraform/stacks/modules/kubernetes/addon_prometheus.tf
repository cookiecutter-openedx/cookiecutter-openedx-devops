#------------------------------------------------------------------------------
#
# see:  https://prometheus.io/
#       https://grafana.com/
#       https://prometheus-operator.dev/docs/prologue/quick-start/
#
# requirements: you must initialize a local helm repo in order to run
# this mdoule.
#
#   brew install helm
#   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts/
#   helm repo update
#   helm search repo prometheus-community
#
# NOTE: run `helm repo update` prior to running this
#       Terraform module.
#-----------------------------------------------------------

resource "helm_release" "prometheus" {
  namespace        = "monitoring"
  create_namespace = true

  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "{{ cookiecutter.terraform_helm_kube_prometheus }}"

  depends_on = [
    module.eks,
  ]
}

resource "kubectl_manifest" "ingress-prometheus" {
  yaml_body = <<-YAML
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: kube-prometheus
    namespace: monitoring
    tls:
    - hosts:
      - "{{ cookiecutter.environment_subdomain }}.{{ cookiecutter.global_root_domain }}"
      - "*.{{ cookiecutter.environment_subdomain }}.{{ cookiecutter.global_root_domain }}"
      secretName: wild-openedx-{{ cookiecutter.environment_name }}-tls
    rules:
    - host: grafana.{{ cookiecutter.environment_subdomain }}.{{ cookiecutter.global_root_domain }}
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: prometheus-grafana
              port:
                number: 3000
  YAML

  depends_on = [
    module.eks,
    helm_release.prometheus,
  ]
}
