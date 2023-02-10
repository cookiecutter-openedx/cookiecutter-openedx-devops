wordpressUsername: ${wordpressUsername}
existingSecret: ${wordpressExistingSecret}
wordpressEmail: ${wordpressEmail}
wordpressFirstName: ${wordpressFirstName}
wordpressLastName: ${wordpressLastName}
wordpressBlogName: ${wordpressBlogName}
wordpressExtraConfigContent: ${wordpressExtraConfigContent}
wordpressConfigureCache: ${wordpressConfigureCache}
wordpressPlugins: ${wordpressPlugins}
allowEmptyPassword: ${allowEmptyPassword}
htaccessPersistenceEnabled: true
extraVolumes: ${extraVolumes}
extraVolumeMounts: ${extraVolumeMounts}
readinessProbe:
  enabled: false
service:
  type: ClusterIP
  annotations: {}
resources:
  limits: {
    memory: 512Mi,
    cpu: 250m
  }
  requests:
    memory: 128Mi
    cpu: 12m
containerPorts:
  http: 8080
  https: 8443
ingress:
  enabled: false
persistence:
  size: ${persistenceSize}
serviceAccount:
  create: ${serviceAccountCreate}
  name: ${serviceAccountName}
  annotations: ${serviceAccountAnnotations}
pdb:
  create: ${PodDisruptionBudgetCreate}
  minAvailable: 1
  maxUnavailable: ""
autoscaling:
  enabled: ${HorizontalAutoscalingCreate}
  minReplicas: ${HorizontalAutoscalingMinReplicas}
  maxReplicas: ${HorizontalAutoscalingMaxReplicas}
  targetMemory: 512Mi
  targetCPU: 250m
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
mariadb:
  enabled: false
externalDatabase:
  host: ${externalDatabaseHost}
  port: ${externalDatabasePort}
  user: ${externalDatabaseUser}
  password: ${externalDatabasePassword}
  database: ${externalDatabaseDatabase}
  existingSecret: ${externalDatabaseExistingSecret}
memcached:
  enabled: ${memcachedEnabled}
externalCache:
  host: ${externalCacheHost}
  port: ${externalCachePort}
