apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: mfe
  namespace: ${environment_namespace}
spec:
  maxReplicas: 10
  minReplicas: 1
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: mfe
  targetCPUUtilizationPercentage: 100
