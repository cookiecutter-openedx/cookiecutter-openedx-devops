apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: vpa-recommender-cert-manager-webhook
  namespace: ${environment_namespace}
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind:       Deployment
    name:       cert-manager-webhook
  updatePolicy:
    updateMode: "Auto"
