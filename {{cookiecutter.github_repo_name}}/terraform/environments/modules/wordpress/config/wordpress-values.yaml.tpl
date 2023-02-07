wordpressUsername: ${wordpressUsername}
wordpressEmail: ${wordpressEmail}
wordpressFirstName: ${wordpressFirstName}
wordpressLastName: ${wordpressLastName}
wordpressBlogName: ${wordpressBlogName}
wordpressExtraConfigContent: ${wordpressExtraConfigContent}
wordpressConfigureCache: ${wordpressConfigureCache}
wordpressPlugins: ${wordpressPlugins}
allowEmptyPassword: ${allowEmptyPassword}
htaccessPersistenceEnabled: false
extraVolumes: ${extraVolumes}
extraVolumeMounts: ${extraVolumeMounts}
resources:
  limits: {}
  requests:
    memory: 512Mi
    cpu: 300m
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
  targetCPU: 50
  targetMemory: 50
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
