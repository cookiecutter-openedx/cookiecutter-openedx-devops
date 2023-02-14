apiVersion: v1
kind: ResourceQuota
metadata:
  name: ${namespace}
  namespace: ${namespace}
spec:
  hard:
    limits.cpu: "${resource_quota_cpu}"
    limits.memory: "${resource_quota_memory}"
