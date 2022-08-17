apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: smtp
  namespace: ${environment_namespace}
spec:
  maxReplicas: 10
  minReplicas: 1
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: smtp
  targetCPUUtilizationPercentage: 100
