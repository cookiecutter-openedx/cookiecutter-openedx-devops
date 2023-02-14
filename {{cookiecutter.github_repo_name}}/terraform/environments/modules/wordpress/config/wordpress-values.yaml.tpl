wordpressUsername: ${wordpressUsername}
existingSecret: ${wordpressExistingSecret}
wordpressEmail: ${wordpressEmail}
wordpressFirstName: ${wordpressFirstName}
wordpressLastName: ${wordpressLastName}
wordpressBlogName: ${wordpressBlogName}
wordpressExtraConfigContent: ${wordpressExtraConfigContent}
wordpressConfigureCache: ${wordpressConfigureCache}
wordpressPlugins: ${wordpressPlugins}
customPostInitScripts:
  writable-files.sh: |
    #!/bin/bash
    touch /opt/bitnami/wordpress/wordfence-waf.php
    touch /bitnami/wordpress/wp-config.php
    touch /bitnami/wordpress/.htaccess
    chmod 664 /bitnami/wordpress/wp-config.php
    chmod 664 /bitnami/wordpress/.htaccess
    cd /bitnami/wordpress/wp-content
    chown -R 1001 .
    chgrp -R 1001 .
    find . -type d -exec chmod 755 {} \;
    find . -type f -exec chmod 644 {} \;
allowEmptyPassword: ${allowEmptyPassword}
htaccessPersistenceEnabled: true
extraVolumes: ${extraVolumes}
extraVolumeMounts: ${extraVolumeMounts}
readinessProbe:
  enabled: false
service:
  type: ClusterIP
  annotations: {}
## @param podAffinityPreset Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
##
podAffinityPreset: ""
## @param podAntiAffinityPreset Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
## Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
##
podAntiAffinityPreset: soft
## Node affinity preset
## Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity
##
nodeAffinityPreset:
  ## @param nodeAffinityPreset.type Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
  ##
  type: ""
  ## @param nodeAffinityPreset.key Node label key to match. Ignored if `affinity` is set
  ##
  key: ""
  ## @param nodeAffinityPreset.values Node label values to match. Ignored if `affinity` is set
  ## E.g.
  ## values:
  ##   - e2e-az1
  ##   - e2e-az2
  ##
  values: []
## @param affinity Affinity for pod assignment
## Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
## NOTE: podAffinityPreset, podAntiAffinityPreset, and nodeAffinityPreset will be ignored when it's set
##
affinity: {}
## @param nodeSelector Node labels for pod assignment
## ref: https://kubernetes.io/docs/user-guide/node-selection/
##
nodeSelector: {}
## @param tolerations Tolerations for pod assignment
## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
##
tolerations:
  - effect: NoSchedule
    key: role
    operator: Equal
    value: pvc-pods
## WordPress containers' resource requests and limits
## ref: https://kubernetes.io/docs/user-guide/compute-resources/
## @param resources.limits The resources limits for the WordPress containers
## @param resources.requests.memory The requested memory for the WordPress containers
## @param resources.requests.cpu The requested cpu for the WordPress containers
##
resources:
  limits:
    memory: "1000Mi"
    cpu: "1000m"
  requests:
    memory: "128Mi"
    cpu: "12m"
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
#externalCache:
#  host: ${externalCacheHost}
#  port: ${externalCachePort}
