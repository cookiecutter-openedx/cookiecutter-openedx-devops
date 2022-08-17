apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: lms
  namespace: ${environment_namespace}
spec:
  maxReplicas: 10
  minReplicas: 2
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: lms
  targetCPUUtilizationPercentage: 500
