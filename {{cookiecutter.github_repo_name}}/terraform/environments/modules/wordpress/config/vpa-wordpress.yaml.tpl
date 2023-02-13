apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: vpa-recommender-wordpress
  namespace: ${namespace}
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind:       Deployment
    name:       wordpress
  updatePolicy:
    updateMode: "Auto"
  # see: https://www.kubecost.com/kubernetes-autoscaling/kubernetes-vpa/
  resourcePolicy:
    containerPolicies:
    - containerName: "wordpress"
      #minAllowed:
      #  cpu: "10m"
      #  memory: "50Mi"
      maxAllowed:
        cpu: "1000m"
        memory: "1000Mi"
