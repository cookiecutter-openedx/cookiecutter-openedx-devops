apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: lms
  namespace: ${environment_namespace}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: lms
  maxReplicas: 25
  minReplicas: 2
  behavior:
    scaleDown:
      policies:
      - type: Pods
        value: 5
        periodSeconds: 300
      - type: Percent
        value: 20
        periodSeconds: 300
      selectPolicy: Max
      stabilizationWindowSeconds: 300
    scaleUp:
      policies:
      - type: Pods
        value: 5
        periodSeconds: 300
      - type: Percent
        value: 50
        periodSeconds: 300
      selectPolicy: Max
      stabilizationWindowSeconds: 0
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: AverageValue
        averageValue: 50m
