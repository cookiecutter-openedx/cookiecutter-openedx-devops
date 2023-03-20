#
# part of the eduNEXT scorm proxy solution
#
kind: Service
apiVersion: v1
metadata:
  name: scorm-proxy-service
  namespace: ${environment_namespace}
spec:
  type: ExternalName
  externalName: ${bucket_uri}
selector: {}
