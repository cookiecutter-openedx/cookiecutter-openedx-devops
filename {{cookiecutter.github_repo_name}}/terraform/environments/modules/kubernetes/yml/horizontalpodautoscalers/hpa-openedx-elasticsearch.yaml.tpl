apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: elasticsearch
  namespace: ${environment_namespace}
spec:
  maxReplicas: 10
  minReplicas: 1
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: elasticsearch
  targetCPUUtilizationPercentage: 100
