apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: discovery
  namespace: ${environment_namespace}
spec:
  maxReplicas: 10
  minReplicas: 1
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: discovery
  targetCPUUtilizationPercentage: 100
