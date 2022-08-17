apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: vpa-recommender-lms
  namespace: ${environment_namespace}
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind:       Deployment
    name:       lms
  updatePolicy:
    updateMode: "Auto"
