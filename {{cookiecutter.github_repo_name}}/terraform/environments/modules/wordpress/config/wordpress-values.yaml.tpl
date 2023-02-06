## @section Global parameters
## Global Docker image parameters
## Please, note that this will override the image parameters, including dependencies, configured to use the global value
## Current available global Docker image parameters: imageRegistry, imagePullSecrets and storageClass
##

## @param global.imageRegistry Global Docker image registry
## @param global.imagePullSecrets Global Docker registry secret names as an array
## @param global.storageClass Global StorageClass for Persistent Volume(s)
##
global:
  imageRegistry: ""
  ## E.g.
  ## imagePullSecrets:
  ##   - myRegistryKeySecretName
  ##
  imagePullSecrets: []
  storageClass: ""

## @section Common parameters
##

## @param kubeVersion Override Kubernetes version
##
kubeVersion: ""
## @param nameOverride String to partially override common.names.fullname template (will maintain the release name)
##
nameOverride: ""
## @param fullnameOverride String to fully override common.names.fullname template
##
fullnameOverride: ""
## @param commonLabels Labels to add to all deployed resources
##
commonLabels: {}
## @param commonAnnotations Annotations to add to all deployed resources
##
commonAnnotations: {}
## @param clusterDomain Kubernetes Cluster Domain
##
clusterDomain: cluster.local
## @param extraDeploy Array of extra objects to deploy with the release
##
extraDeploy: []

## Enable diagnostic mode in the deployment
##
diagnosticMode:
  ## @param diagnosticMode.enabled Enable diagnostic mode (all probes will be disabled and the command will be overridden)
  ##
  enabled: false
  ## @param diagnosticMode.command Command to override all containers in the deployment
  ##
  command:
    - sleep
  ## @param diagnosticMode.args Args to override all containers in the deployment
  ##
  args:
    - infinity

## @section WordPress Image parameters
##

## Bitnami WordPress image
## ref: https://hub.docker.com/r/bitnami/wordpress/tags/
## @param image.registry WordPress image registry
## @param image.repository WordPress image repository
## @param image.tag WordPress image tag (immutable tags are recommended)
## @param image.digest WordPress image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag
## @param image.pullPolicy WordPress image pull policy
## @param image.pullSecrets WordPress image pull secrets
## @param image.debug Specify if debug values should be set
##
image:
  registry: docker.io
  repository: bitnami/wordpress
  tag: 6.1.1-debian-11-r40
  digest: ""
  ## Specify a imagePullPolicy
  ## Defaults to 'Always' if image tag is 'latest', else set to 'IfNotPresent'
  ## ref: https://kubernetes.io/docs/user-guide/images/#pre-pulling-images
  ##
  pullPolicy: IfNotPresent
  ## Optionally specify an array of imagePullSecrets.
  ## Secrets must be manually created in the namespace.
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
  ## e.g:
  ## pullSecrets:
  ##   - myRegistryKeySecretName
  ##
  pullSecrets: []
  ## Enable debug mode
  ##
  debug: false

## @section WordPress Configuration parameters
## WordPress settings based on environment variables
## ref: https://github.com/bitnami/containers/tree/main/bitnami/wordpress#environment-variables
##
wordpressUsername: ${wordpressUsername}
## @param existingSecret Name of existing secret containing WordPress credentials
## NOTE: Must contain key `wordpress-password`
## NOTE: When it's set, the `wordpressPassword` parameter is ignored
##
existingSecret: ""
## @param wordpressEmail WordPress user email
##
wordpressEmail: ${wordpressEmail}
## @param wordpressFirstName WordPress user first name
##
wordpressFirstName: ${wordpressFirstName}
## @param wordpressLastName WordPress user last name
##
wordpressLastName: ${wordpressLastName}
## @param wordpressBlogName Blog name
##
wordpressBlogName: ${wordpressBlogName}
## @param wordpressTablePrefix Prefix to use for WordPress database tables
##
wordpressExtraConfigContent: ${wordpressExtraConfigContent}
## @param wordpressConfiguration The content for your custom wp-config.php file (advanced feature)
## NOTE: This will override configuring WordPress based on environment variables (including those set by the chart)
## NOTE: Currently only supported when `wordpressSkipInstall=true`
##
wordpressConfiguration: ""
## @param existingWordPressConfigurationSecret The name of an existing secret with your custom wp-config.php file (advanced feature)
## NOTE: When it's set the `wordpressConfiguration` parameter is ignored
##
existingWordPressConfigurationSecret: ""
## @param wordpressConfigureCache Enable W3 Total Cache plugin and configure cache settings
## NOTE: useful if you deploy Memcached for caching database queries or you use an external cache server
##
wordpressConfigureCache: ${wordpressConfigureCache}
## @param wordpressPlugins Array of plugins to install and activate. Can be specified as `all` or `none`.
## NOTE: If set to all, only plugins that are already installed will be activated, and if set to none, no plugins will be activated
##
wordpressPlugins: ${wordpressPlugins}
## @param apacheConfiguration The content for your custom httpd.conf file (advanced feature)
##
apacheConfiguration: ""
## @param existingApacheConfigurationConfigMap The name of an existing secret with your custom httpd.conf file (advanced feature)
## NOTE: When it's set the `apacheConfiguration` parameter is ignored
##
existingApacheConfigurationConfigMap: ""
## @param customPostInitScripts Custom post-init.d user scripts
## ref: https://github.com/bitnami/containers/tree/main/bitnami/wordpress
## NOTE: supported formats are `.sh`, `.sql` or `.php`
## NOTE: scripts are exclusively executed during the 1st boot of the container
## e.g:
## customPostInitScripts:
##   enable-multisite.sh: |
##     #!/bin/bash
##     chmod +w /bitnami/wordpress/wp-config.php
##     wp core multisite-install --url=example.com --title="Welcome to the WordPress Multisite" --admin_user="doesntmatternotreallyused" --admin_password="doesntmatternotreallyused" --admin_email="user@example.com"
##     cat /docker-entrypoint-init.d/.htaccess > /bitnami/wordpress/.htaccess
##     chmod -w bitnami/wordpress/wp-config.php
##   .htaccess: |
##     RewriteEngine On
##     RewriteBase /
##     ...
##
customPostInitScripts: {}
## SMTP mail delivery configuration
## ref: https://github.com/bitnami/containers/tree/main/bitnami/wordpress/#smtp-configuration
## @param smtpHost SMTP server host
## @param smtpPort SMTP server port
## @param smtpUser SMTP username
## @param smtpPassword SMTP user password
## @param smtpProtocol SMTP protocol
##
smtpHost: ""
smtpPort: ""
smtpUser: ""
smtpProtocol: ""
## @param smtpExistingSecret The name of an existing secret with SMTP credentials
## NOTE: Must contain key `smtp-password`
## NOTE: When it's set, the `smtpPassword` parameter is ignored
##
smtpExistingSecret: ""
## @param allowEmptyPassword Allow the container to be started with blank passwords
##
allowEmptyPassword: ${allowEmptyPassword}
## @param allowOverrideNone Configure Apache to prohibit overriding directives with htaccess files
##
allowOverrideNone: false
## @param overrideDatabaseSettings Allow overriding the database settings persisted in wp-config.php
##
overrideDatabaseSettings: false
## @param htaccessPersistenceEnabled Persist custom changes on htaccess files
## If `allowOverrideNone` is `false`, it will persist `/opt/bitnami/wordpress/wordpress-htaccess.conf`
## If `allowOverrideNone` is `true`, it will persist `/opt/bitnami/wordpress/.htaccess`
##
htaccessPersistenceEnabled: false
## @param customHTAccessCM The name of an existing ConfigMap with custom htaccess rules
## NOTE: Must contain key `wordpress-htaccess.conf` with the file content
## NOTE: Requires setting `allowOverrideNone=false`
##
customHTAccessCM: ""
## @param command Override default container command (useful when using custom images)
##
command: []
## @param args Override default container args (useful when using custom images)
##
args: []
## @param extraEnvVars Array with extra environment variables to add to the WordPress container
## e.g:
## extraEnvVars:
##   - name: FOO
##     value: "bar"
##
extraEnvVars: []
## @param extraEnvVarsCM Name of existing ConfigMap containing extra env vars
##
extraEnvVarsCM: ""
## @param extraEnvVarsSecret Name of existing Secret containing extra env vars
##
extraEnvVarsSecret: ""

## @section WordPress Multisite Configuration parameters
## ref: https://github.com/bitnami/containers/tree/main/bitnami/wordpress#multisite-configuration
##

## @param multisite.enable Whether to enable WordPress Multisite configuration.
## @param multisite.host WordPress Multisite hostname/address. This value is mandatory when enabling Multisite mode.
## @param multisite.networkType WordPress Multisite network type to enable. Allowed values: `subfolder`, `subdirectory` or `subdomain`.
## @param multisite.enableNipIoRedirect Whether to enable IP address redirection to nip.io wildcard DNS. Useful when running on an IP address with subdomain network type.
##
multisite:
  enable: false
  host: ""
  networkType: subdomain
  enableNipIoRedirect: false

## @section WordPress deployment parameters
##

## @param replicaCount Number of WordPress replicas to deploy
## NOTE: ReadWriteMany PVC(s) are required if replicaCount > 1
##
replicaCount: 1
## @param updateStrategy.type WordPress deployment strategy type
## @param updateStrategy.rollingUpdate WordPress deployment rolling update configuration parameters
## ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy
## NOTE: Set it to `Recreate` if you use a PV that cannot be mounted on multiple pods
## e.g:
## updateStrategy:
##  type: RollingUpdate
##  rollingUpdate:
##    maxSurge: 25%
##    maxUnavailable: 25%
##
updateStrategy:
  type: RollingUpdate
  rollingUpdate: {}
## @param schedulerName Alternate scheduler
## ref: https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
##
schedulerName: ""
## @param topologySpreadConstraints Topology Spread Constraints for pod assignment spread across your cluster among failure-domains. Evaluated as a template
## Ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/#spread-constraints-for-pods
##
topologySpreadConstraints: []
## @param priorityClassName Name of the existing priority class to be used by WordPress pods, priority class needs to be created beforehand
## Ref: https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/
##
priorityClassName: ""
## @param hostAliases [array] WordPress pod host aliases
## https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/
##
hostAliases:
  ## Required for Apache exporter to work
  ##
  - ip: "127.0.0.1"
    hostnames:
      - "status.localhost"
## @param extraVolumes Optionally specify extra list of additional volumes for WordPress pods
##
extraVolumes: ${extraVolumes}
## @param extraVolumeMounts Optionally specify extra list of additional volumeMounts for WordPress container(s)
##
extraVolumeMounts: ${extraVolumeMounts}
## @param sidecars Add additional sidecar containers to the WordPress pod
## e.g:
## sidecars:
##   - name: your-image-name
##     image: your-image
##     imagePullPolicy: Always
##     ports:
##       - name: portname
##         containerPort: 1234
##
sidecars: []
## @param initContainers Add additional init containers to the WordPress pods
## ref: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/
## e.g:
## initContainers:
##  - name: your-image-name
##    image: your-image
##    imagePullPolicy: Always
##    command: ['sh', '-c', 'copy themes and plugins from git and push to /bitnami/wordpress/wp-content. Should work with extraVolumeMounts and extraVolumes']
##
initContainers: []
## @param podLabels Extra labels for WordPress pods
## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
##
podLabels:
## @param podAnnotations Annotations for WordPress pods
## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/
##
podAnnotations:
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
nodeSelector:
## @param tolerations Tolerations for pod assignment
## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
##
tolerations: []
## WordPress containers' resource requests and limits
## ref: https://kubernetes.io/docs/user-guide/compute-resources/
## @param resources.limits The resources limits for the WordPress containers
## @param resources.requests.memory The requested memory for the WordPress containers
## @param resources.requests.cpu The requested cpu for the WordPress containers
##
resources:
  limits: {}
  requests:
    memory: 512Mi
    cpu: 300m
## Container ports
## @param containerPorts.http WordPress HTTP container port
## @param containerPorts.https WordPress HTTPS container port
##
containerPorts:
  http: 8080
  https: 8443
## @param extraContainerPorts Optionally specify extra list of additional ports for WordPress container(s)
## e.g:
## extraContainerPorts:
##   - name: myservice
##     containerPort: 9090
##
extraContainerPorts: []
## Configure Pods Security Context
## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod
## @param podSecurityContext.enabled Enabled WordPress pods' Security Context
## @param podSecurityContext.fsGroup Set WordPress pod's Security Context fsGroup
## @param podSecurityContext.seccompProfile.type Set WordPress container's Security Context seccomp profile
##
podSecurityContext:
  enabled: true
  fsGroup: 1001
  seccompProfile:
    type: "RuntimeDefault"
## Configure Container Security Context (only main container)
## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container
## @param containerSecurityContext.enabled Enabled WordPress containers' Security Context
## @param containerSecurityContext.runAsUser Set WordPress container's Security Context runAsUser
## @param containerSecurityContext.runAsNonRoot Set WordPress container's Security Context runAsNonRoot
## @param containerSecurityContext.allowPrivilegeEscalation Set WordPress container's privilege escalation
## @param containerSecurityContext.capabilities.drop Set WordPress container's Security Context runAsNonRoot
##
containerSecurityContext:
  enabled: true
  runAsUser: 1001
  runAsNonRoot: true
  allowPrivilegeEscalation: false
  capabilities:
    drop: ["ALL"]
## Configure extra options for WordPress containers' liveness, readiness and startup probes
## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes
## @param livenessProbe.enabled Enable livenessProbe on WordPress containers
## @skip livenessProbe.httpGet
## @param livenessProbe.initialDelaySeconds Initial delay seconds for livenessProbe
## @param livenessProbe.periodSeconds Period seconds for livenessProbe
## @param livenessProbe.timeoutSeconds Timeout seconds for livenessProbe
## @param livenessProbe.failureThreshold Failure threshold for livenessProbe
## @param livenessProbe.successThreshold Success threshold for livenessProbe
##
livenessProbe:
  enabled: true
  httpGet:
    path: /wp-admin/install.php
    port: '{% raw %}{{ .Values.wordpressScheme }}{% endraw %}'
    scheme: '{% raw %}{{ .Values.wordpressScheme | upper }}{% endraw %}'
    ## If using an HTTPS-terminating load-balancer, the probes may need to behave
    ## like the balancer to prevent HTTP 302 responses. According to the Kubernetes
    ## docs, 302 should be considered "successful", but this issue on GitHub
    ## (https://github.com/kubernetes/kubernetes/issues/47893) shows that it isn't.
    ## E.g.
    ## httpHeaders:
    ## - name: X-Forwarded-Proto
    ##   value: https
    ##
    httpHeaders: []
  initialDelaySeconds: 120
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 6
  successThreshold: 1
## @param readinessProbe.enabled Enable readinessProbe on WordPress containers
## @skip readinessProbe.httpGet
## @param readinessProbe.initialDelaySeconds Initial delay seconds for readinessProbe
## @param readinessProbe.periodSeconds Period seconds for readinessProbe
## @param readinessProbe.timeoutSeconds Timeout seconds for readinessProbe
## @param readinessProbe.failureThreshold Failure threshold for readinessProbe
## @param readinessProbe.successThreshold Success threshold for readinessProbe
##
readinessProbe:
  enabled: true
  httpGet:
    path: /wp-login.php
    port: '{% raw %}{{ .Values.wordpressScheme }}{% endraw %}'
    scheme: '{% raw %}{{ .Values.wordpressScheme | upper }}{% endraw %}'
    ## If using an HTTPS-terminating load-balancer, the probes may need to behave
    ## like the balancer to prevent HTTP 302 responses. According to the Kubernetes
    ## docs, 302 should be considered "successful", but this issue on GitHub
    ## (https://github.com/kubernetes/kubernetes/issues/47893) shows that it isn't.
    ## E.g.
    ## httpHeaders:
    ## - name: X-Forwarded-Proto
    ##   value: https
    ##
    httpHeaders: []
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 6
  successThreshold: 1
## @param startupProbe.enabled Enable startupProbe on WordPress containers
## @skip startupProbe.httpGet
## @param startupProbe.initialDelaySeconds Initial delay seconds for startupProbe
## @param startupProbe.periodSeconds Period seconds for startupProbe
## @param startupProbe.timeoutSeconds Timeout seconds for startupProbe
## @param startupProbe.failureThreshold Failure threshold for startupProbe
## @param startupProbe.successThreshold Success threshold for startupProbe
##
startupProbe:
  enabled: false
  httpGet:
    path: /wp-login.php
    port: '{% raw %}{{ .Values.wordpressScheme }}{% endraw %}'
    scheme: '{% raw %}{{ .Values.wordpressScheme | upper }}{% endraw %}'
    ## If using an HTTPS-terminating load-balancer, the probes may need to behave
    ## like the balancer to prevent HTTP 302 responses. According to the Kubernetes
    ## docs, 302 should be considered "successful", but this issue on GitHub
    ## (https://github.com/kubernetes/kubernetes/issues/47893) shows that it isn't.
    ## E.g.
    ## httpHeaders:
    ## - name: X-Forwarded-Proto
    ##   value: https
    ##
    httpHeaders: []
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 6
  successThreshold: 1
## @param customLivenessProbe Custom livenessProbe that overrides the default one
##
customLivenessProbe: {}
## @param customReadinessProbe Custom readinessProbe that overrides the default one
##
customReadinessProbe: {}
## @param customStartupProbe Custom startupProbe that overrides the default one
##
customStartupProbe: {}
## @param lifecycleHooks for the WordPress container(s) to automate configuration before or after startup
##
lifecycleHooks: {}

## @section Traffic Exposure Parameters
##

## WordPress service parameters
##
service:
  ## @param service.type WordPress service type
  ##
  type: LoadBalancer
  ## @param service.ports.http WordPress service HTTP port
  ## @param service.ports.https WordPress service HTTPS port
  ##
  ports:
    http: 80
    https: 443
  ## @param service.httpsTargetPort Target port for HTTPS
  ##
  httpsTargetPort: https
  ## Node ports to expose
  ## @param service.nodePorts.http Node port for HTTP
  ## @param service.nodePorts.https Node port for HTTPS
  ## NOTE: choose port between <30000-32767>
  ##
  nodePorts:
    http: ""
    https: ""
  ## @param service.sessionAffinity Control where client requests go, to the same pod or round-robin
  ## Values: ClientIP or None
  ## ref: https://kubernetes.io/docs/user-guide/services/
  ##
  sessionAffinity: None
  ## @param service.sessionAffinityConfig Additional settings for the sessionAffinity
  ## sessionAffinityConfig:
  ##   clientIP:
  ##     timeoutSeconds: 300
  ##
  sessionAffinityConfig: {}
  ## @param service.clusterIP WordPress service Cluster IP
  ## e.g.:
  ## clusterIP: None
  ##
  clusterIP: ""
  ## @param service.loadBalancerIP WordPress service Load Balancer IP
  ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#type-loadbalancer
  ##
  loadBalancerIP: ""
  ## @param service.loadBalancerSourceRanges WordPress service Load Balancer sources
  ## ref: https://kubernetes.io/docs/tasks/access-application-cluster/configure-cloud-provider-firewall/#restrict-access-for-loadbalancer-service
  ## e.g:
  ## loadBalancerSourceRanges:
  ##   - 10.10.10.0/24
  ##
  loadBalancerSourceRanges: []
  ## @param service.externalTrafficPolicy WordPress service external traffic policy
  ## ref https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip
  ##
  externalTrafficPolicy: Cluster
  ## @param service.annotations Additional custom annotations for WordPress service
  ##
  annotations: {}
  ## @param service.extraPorts Extra port to expose on WordPress service
  ##
  extraPorts: []
## Configure the ingress resource that allows you to access the WordPress installation
## ref: https://kubernetes.io/docs/concepts/services-networking/ingress/
##
ingress:
  ## @param ingress.enabled Enable ingress record generation for WordPress
  ##
  enabled: false
  ## @param ingress.pathType Ingress path type
  ##
  pathType: ImplementationSpecific
  ## @param ingress.apiVersion Force Ingress API version (automatically detected if not set)
  ##
  apiVersion: ""
  ## @param ingress.ingressClassName IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+)
  ## This is supported in Kubernetes 1.18+ and required if you have more than one IngressClass marked as the default for your cluster .
  ## ref: https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/
  ##
  ingressClassName: ""
  ## @param ingress.hostname Default host for the ingress record
  ##
  hostname: wordpress.local
  ## @param ingress.path Default path for the ingress record
  ## NOTE: You may need to set this to '/*' in order to use this with ALB ingress controllers
  ##
  path: /
  ## @param ingress.annotations Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations.
  ## For a full list of possible ingress annotations, please see
  ## ref: https://github.com/kubernetes/ingress-nginx/blob/master/docs/user-guide/nginx-configuration/annotations.md
  ## Use this parameter to set the required annotations for cert-manager, see
  ## ref: https://cert-manager.io/docs/usage/ingress/#supported-annotations
  ##
  ## e.g:
  ## annotations:
  ##   kubernetes.io/ingress.class: nginx
  ##   cert-manager.io/cluster-issuer: cluster-issuer-name
  ##
  annotations: {}
  ## @param ingress.tls Enable TLS configuration for the host defined at `ingress.hostname` parameter
  ## TLS certificates will be retrieved from a TLS secret with name: `{% raw %}{{- printf "%s-tls" .Values.ingress.hostname }}{% endraw %}`
  ## You can:
  ##   - Use the `ingress.secrets` parameter to create this TLS secret
  ##   - Rely on cert-manager to create it by setting the corresponding annotations
  ##   - Rely on Helm to create self-signed certificates by setting `ingress.selfSigned=true`
  ##
  tls: false
  ## @param ingress.tlsWwwPrefix Adds www subdomain to default cert
  ## Creates tls host with ingress.hostname: {% raw %}{{ print "www.%s" .Values.ingress.hostname }}{% endraw %}
  ## Is enabled if "nginx.ingress.kubernetes.io/from-to-www-redirect" is "true"
  tlsWwwPrefix: false
  ## @param ingress.selfSigned Create a TLS secret for this ingress record using self-signed certificates generated by Helm
  ##
  selfSigned: false
  ## @param ingress.extraHosts An array with additional hostname(s) to be covered with the ingress record
  ## e.g:
  ## extraHosts:
  ##   - name: wordpress.local
  ##     path: /
  ##
  extraHosts: []
  ## @param ingress.extraPaths An array with additional arbitrary paths that may need to be added to the ingress under the main host
  ## e.g:
  ## extraPaths:
  ## - path: /*
  ##   backend:
  ##     serviceName: ssl-redirect
  ##     servicePort: use-annotation
  ##
  extraPaths: []
  ## @param ingress.extraTls TLS configuration for additional hostname(s) to be covered with this ingress record
  ## ref: https://kubernetes.io/docs/concepts/services-networking/ingress/#tls
  ## e.g:
  ## extraTls:
  ## - hosts:
  ##     - wordpress.local
  ##   secretName: wordpress.local-tls
  ##
  extraTls: []
  ## @param ingress.secrets Custom TLS certificates as secrets
  ## NOTE: 'key' and 'certificate' are expected in PEM format
  ## NOTE: 'name' should line up with a 'secretName' set further up
  ## If it is not set and you're using cert-manager, this is unneeded, as it will create a secret for you with valid certificates
  ## If it is not set and you're NOT using cert-manager either, self-signed certificates will be created valid for 365 days
  ## It is also possible to create and manage the certificates outside of this helm chart
  ## Please see README.md for more information
  ## e.g:
  ## secrets:
  ##   - name: wordpress.local-tls
  ##     key: |-
  ##     certificate: |-
  ##
  secrets: []
  ## @param ingress.extraRules Additional rules to be covered with this ingress record
  ## ref: https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-rules
  ## e.g:
  ## extraRules:
  ## - host: wordpress.local
  ##     http:
  ##       path: /
  ##       backend:
  ##         service:
  ##           name: wordpress-svc
  ##           port:
  ##             name: http
  ##
  extraRules: []

## @section Persistence Parameters
##

## Persistence Parameters
## ref: https://kubernetes.io/docs/user-guide/persistent-volumes/
##
persistence:
  ## @param persistence.enabled Enable persistence using Persistent Volume Claims
  ##
  enabled: true
  ## @param persistence.storageClass Persistent Volume storage class
  ## If defined, storageClassName: <storageClass>
  ## If set to "-", storageClassName: "", which disables dynamic provisioning
  ## If undefined (the default) or set to null, no storageClassName spec is set, choosing the default provisioner
  ##
  storageClass: ""
  ## @param persistence.accessModes [array] Persistent Volume access modes
  ##
  accessModes:
    - ReadWriteOnce
  ## @param persistence.accessMode Persistent Volume access mode (DEPRECATED: use `persistence.accessModes` instead)
  ##
  accessMode: ReadWriteOnce
  ## @param persistence.size Persistent Volume size
  ##
  size: 10Gi
  ## @param persistence.dataSource Custom PVC data source
  ##
  dataSource: {}
  ## @param persistence.existingClaim The name of an existing PVC to use for persistence
  ##
  existingClaim:
  ## @param persistence.selector Selector to match an existing Persistent Volume for WordPress data PVC
  ## If set, the PVC can't have a PV dynamically provisioned for it
  ## E.g.
  ## selector:
  ##   matchLabels:
  ##     app: my-app
  ##
  selector:
## Init containers parameters:
## volumePermissions: Change the owner and group of the persistent volume(s) mountpoint(s) to 'runAsUser:fsGroup' on each node
##
volumePermissions:
  ## @param volumePermissions.enabled Enable init container that changes the owner/group of the PV mount point to `runAsUser:fsGroup`
  ##
  enabled: false
  ## Bitnami Shell image
  ## ref: https://hub.docker.com/r/bitnami/bitnami-shell/tags/
  ## @param volumePermissions.image.registry Bitnami Shell image registry
  ## @param volumePermissions.image.repository Bitnami Shell image repository
  ## @param volumePermissions.image.tag Bitnami Shell image tag (immutable tags are recommended)
  ## @param volumePermissions.image.digest Bitnami Shell image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag
  ## @param volumePermissions.image.pullPolicy Bitnami Shell image pull policy
  ## @param volumePermissions.image.pullSecrets Bitnami Shell image pull secrets
  ##
  image:
    registry: docker.io
    repository: bitnami/bitnami-shell
    tag: 11-debian-11-r79
    digest: ""
    pullPolicy: IfNotPresent
    ## Optionally specify an array of imagePullSecrets.
    ## Secrets must be manually created in the namespace.
    ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
    ## e.g:
    ## pullSecrets:
    ##   - myRegistryKeySecretName
    ##
    pullSecrets: []
  ## Init container's resource requests and limits
  ## ref: https://kubernetes.io/docs/user-guide/compute-resources/
  ## @param volumePermissions.resources.limits The resources limits for the init container
  ## @param volumePermissions.resources.requests The requested resources for the init container
  ##
  resources:
    limits: {}
    requests: {}
  ## Init container' Security Context
  ## Note: the chown of the data folder is done to containerSecurityContext.runAsUser
  ## and not the below volumePermissions.containerSecurityContext.runAsUser
  ## @param volumePermissions.containerSecurityContext.runAsUser User ID for the init container
  ##
  containerSecurityContext:
    runAsUser: 0

## @section Other Parameters
##

## WordPress Service Account
## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
##
serviceAccount:
  ## @param serviceAccount.create Enable creation of ServiceAccount for WordPress pod
  ##
  create: ${serviceAccountCreate}
  ## @param serviceAccount.name The name of the ServiceAccount to use.
  ## If not set and create is true, a name is generated using the common.names.fullname template
  ##
  name: ${serviceAccountName}
  ## @param serviceAccount.automountServiceAccountToken Allows auto mount of ServiceAccountToken on the serviceAccount created
  ## Can be set to false if pods using this serviceAccount do not need to use K8s API
  ##
  automountServiceAccountToken: true
  ## @param serviceAccount.annotations Additional custom annotations for the ServiceAccount
  ##
  annotations: ${serviceAccountAnnotations}
## WordPress Pod Disruption Budget configuration
## ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/
## @param pdb.create Enable a Pod Disruption Budget creation
## @param pdb.minAvailable Minimum number/percentage of pods that should remain scheduled
## @param pdb.maxUnavailable Maximum number/percentage of pods that may be made unavailable
##
pdb:
  create: ${PodDisruptionBudgetCreate}
  minAvailable: 1
  maxUnavailable: ""
## WordPress Autoscaling configuration
## ref: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/
## @param autoscaling.enabled Enable Horizontal POD autoscaling for WordPress
## @param autoscaling.minReplicas Minimum number of WordPress replicas
## @param autoscaling.maxReplicas Maximum number of WordPress replicas
## @param autoscaling.targetCPU Target CPU utilization percentage
## @param autoscaling.targetMemory Target Memory utilization percentage
##
autoscaling:
  enabled: ${HorizontalAutoscalingCreate}
  minReplicas: ${HorizontalAutoscalingMinReplicas}
  maxReplicas: ${HorizontalAutoscalingMaxReplicas}
  targetCPU: 50
  targetMemory: 50

## @section Metrics Parameters
##

## Prometheus Exporter / Metrics configuration
##
metrics:
  ## @param metrics.enabled Start a sidecar prometheus exporter to expose metrics
  ##
  enabled: false
  ## Bitnami Apache exporter image
  ## ref: https://hub.docker.com/r/bitnami/apache-exporter/tags/
  ## @param metrics.image.registry Apache exporter image registry
  ## @param metrics.image.repository Apache exporter image repository
  ## @param metrics.image.tag Apache exporter image tag (immutable tags are recommended)
  ## @param metrics.image.digest Apache exporter image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag
  ## @param metrics.image.pullPolicy Apache exporter image pull policy
  ## @param metrics.image.pullSecrets Apache exporter image pull secrets
  ##
  image:
    registry: docker.io
    repository: bitnami/apache-exporter
    tag: 0.11.0-debian-11-r88
    digest: ""
    pullPolicy: IfNotPresent
    ## Optionally specify an array of imagePullSecrets.
    ## Secrets must be manually created in the namespace.
    ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
    ## e.g:
    ## pullSecrets:
    ##   - myRegistryKeySecretName
    ##
    pullSecrets: []
  ## @param metrics.containerPorts.metrics Prometheus exporter container port
  ##
  containerPorts:
    metrics: 9117
  ## Configure extra options for Prometheus exporter containers' liveness, readiness and startup probes
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes
  ## @param metrics.livenessProbe.enabled Enable livenessProbe on Prometheus exporter containers
  ## @param metrics.livenessProbe.initialDelaySeconds Initial delay seconds for livenessProbe
  ## @param metrics.livenessProbe.periodSeconds Period seconds for livenessProbe
  ## @param metrics.livenessProbe.timeoutSeconds Timeout seconds for livenessProbe
  ## @param metrics.livenessProbe.failureThreshold Failure threshold for livenessProbe
  ## @param metrics.livenessProbe.successThreshold Success threshold for livenessProbe
  ##
  livenessProbe:
    enabled: true
    initialDelaySeconds: 15
    periodSeconds: 10
    timeoutSeconds: 5
    failureThreshold: 3
    successThreshold: 1
  ## @param metrics.readinessProbe.enabled Enable readinessProbe on Prometheus exporter containers
  ## @param metrics.readinessProbe.initialDelaySeconds Initial delay seconds for readinessProbe
  ## @param metrics.readinessProbe.periodSeconds Period seconds for readinessProbe
  ## @param metrics.readinessProbe.timeoutSeconds Timeout seconds for readinessProbe
  ## @param metrics.readinessProbe.failureThreshold Failure threshold for readinessProbe
  ## @param metrics.readinessProbe.successThreshold Success threshold for readinessProbe
  ##
  readinessProbe:
    enabled: true
    initialDelaySeconds: 5
    periodSeconds: 10
    timeoutSeconds: 3
    failureThreshold: 3
    successThreshold: 1
  ## @param metrics.startupProbe.enabled Enable startupProbe on Prometheus exporter containers
  ## @param metrics.startupProbe.initialDelaySeconds Initial delay seconds for startupProbe
  ## @param metrics.startupProbe.periodSeconds Period seconds for startupProbe
  ## @param metrics.startupProbe.timeoutSeconds Timeout seconds for startupProbe
  ## @param metrics.startupProbe.failureThreshold Failure threshold for startupProbe
  ## @param metrics.startupProbe.successThreshold Success threshold for startupProbe
  ##
  startupProbe:
    enabled: false
    initialDelaySeconds: 10
    periodSeconds: 10
    timeoutSeconds: 1
    failureThreshold: 15
    successThreshold: 1
  ## @param metrics.customLivenessProbe Custom livenessProbe that overrides the default one
  ##
  customLivenessProbe: {}
  ## @param metrics.customReadinessProbe Custom readinessProbe that overrides the default one
  ##
  customReadinessProbe: {}
  ## @param metrics.customStartupProbe Custom startupProbe that overrides the default one
  ##
  customStartupProbe: {}
  ## Prometheus exporter container's resource requests and limits
  ## ref: https://kubernetes.io/docs/user-guide/compute-resources/
  ## @param metrics.resources.limits The resources limits for the Prometheus exporter container
  ## @param metrics.resources.requests The requested resources for the Prometheus exporter container
  ##
  resources:
    limits: {}
    requests: {}
  ## Prometheus exporter service parameters
  ##
  service:
    ## @param metrics.service.ports.metrics Prometheus metrics service port
    ##
    ports:
      metrics: 9150
    ## @param metrics.service.annotations [object] Additional custom annotations for Metrics service
    ##
    annotations:
      prometheus.io/scrape: "true"
      prometheus.io/port: "{% raw %}{{ .Values.metrics.containerPorts.metrics }}{% endraw %}"
  ## Prometheus Operator ServiceMonitor configuration
  ##
  serviceMonitor:
    ## @param metrics.serviceMonitor.enabled Create ServiceMonitor Resource for scraping metrics using Prometheus Operator
    ##
    enabled: false
    ## @param metrics.serviceMonitor.namespace Namespace for the ServiceMonitor Resource (defaults to the Release Namespace)
    ##
    namespace: ""
    ## @param metrics.serviceMonitor.interval Interval at which metrics should be scraped.
    ## ref: https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#endpoint
    ##
    interval: ""
    ## @param metrics.serviceMonitor.scrapeTimeout Timeout after which the scrape is ended
    ## ref: https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#endpoint
    ##
    scrapeTimeout: ""
    ## @param metrics.serviceMonitor.labels Additional labels that can be used so ServiceMonitor will be discovered by Prometheus
    ##
    labels: {}
    ## @param metrics.serviceMonitor.selector Prometheus instance selector labels
    ## ref: https://github.com/bitnami/charts/tree/main/bitnami/prometheus-operator#prometheus-configuration
    ##
    selector: {}
    ## @param metrics.serviceMonitor.relabelings RelabelConfigs to apply to samples before scraping
    ##
    relabelings: []
    ## @param metrics.serviceMonitor.metricRelabelings MetricRelabelConfigs to apply to samples before ingestion
    ##
    metricRelabelings: []
    ## @param metrics.serviceMonitor.honorLabels Specify honorLabels parameter to add the scrape endpoint
    ##
    honorLabels: false
    ## @param metrics.serviceMonitor.jobLabel The name of the label on the target service to use as the job name in prometheus.
    ##
    jobLabel: ""

## @section NetworkPolicy parameters
##

## Add networkpolicies
##
networkPolicy:
  ## @param networkPolicy.enabled Enable network policies
  ## If ingress.enabled or metrics.enabled are true, configure networkPolicy.ingress and networkPolicy.metrics selectors respectively to allow communication
  ##
  enabled: false
  ## @param networkPolicy.metrics.enabled Enable network policy for metrics (prometheus)
  ## @param networkPolicy.metrics.namespaceSelector [object] Monitoring namespace selector labels. These labels will be used to identify the prometheus' namespace.
  ## @param networkPolicy.metrics.podSelector [object] Monitoring pod selector labels. These labels will be used to identify the Prometheus pods.
  ##
  metrics:
    enabled: false
    ## e.g:
    ## podSelector:
    ##   label: monitoring
    ##
    podSelector: {}
    ## e.g:
    ## namespaceSelector:
    ##   label: monitoring
    ##
    namespaceSelector: {}
  ## @param networkPolicy.ingress.enabled Enable network policy for Ingress Proxies
  ## @param networkPolicy.ingress.namespaceSelector [object] Ingress Proxy namespace selector labels. These labels will be used to identify the Ingress Proxy's namespace.
  ## @param networkPolicy.ingress.podSelector [object] Ingress Proxy pods selector labels. These labels will be used to identify the Ingress Proxy pods.
  ##
  ingress:
    enabled: false
    ## e.g:
    ## podSelector:
    ##   label: ingress
    ##
    podSelector: {}
    ## e.g:
    ## namespaceSelector:
    ##   label: ingress
    ##
    namespaceSelector: {}
  ## @param networkPolicy.ingressRules.backendOnlyAccessibleByFrontend Enable ingress rule that makes the backend (mariadb) only accessible by testlink's pods.
  ## @param networkPolicy.ingressRules.customBackendSelector [object] Backend selector labels. These labels will be used to identify the backend pods.
  ## @param networkPolicy.ingressRules.accessOnlyFrom.enabled Enable ingress rule that makes testlink only accessible from a particular origin
  ## @param networkPolicy.ingressRules.accessOnlyFrom.namespaceSelector [object] Namespace selector label that is allowed to access testlink. This label will be used to identified the allowed namespace(s).
  ## @param networkPolicy.ingressRules.accessOnlyFrom.podSelector [object] Pods selector label that is allowed to access testlink. This label will be used to identified the allowed pod(s).
  ## @param networkPolicy.ingressRules.customRules [object] Custom network policy ingress rule
  ##
  ingressRules:
    ## mariadb backend only can be accessed from testlink
    ##
    backendOnlyAccessibleByFrontend: false
    ## Additional custom backend selector
    ## e.g:
    ## customBackendSelector:
    ##   - to:
    ##       - namespaceSelector:
    ##           matchLabels:
    ##             label: example
    ##
    customBackendSelector: {}
    ## Allow only from the indicated:
    ##
    accessOnlyFrom:
      enabled: false
      ## e.g:
      ## podSelector:
      ##   label: access
      ##
      podSelector: {}
      ## e.g:
      ## namespaceSelector:
      ##   label: access
      ##
      namespaceSelector: {}
    ## custom ingress rules
    ## e.g:
    ## customRules:
    ##   - from:
    ##       - namespaceSelector:
    ##           matchLabels:
    ##             label: example
    ##
    customRules: {}
  ## @param networkPolicy.egressRules.denyConnectionsToExternal Enable egress rule that denies outgoing traffic outside the cluster, except for DNS (port 53).
  ## @param networkPolicy.egressRules.customRules [object] Custom network policy rule
  ##
  egressRules:
    # Deny connections to external. This is not compatible with an external database.
    denyConnectionsToExternal: false
    ## Additional custom egress rules
    ## e.g:
    ## customRules:
    ##   - to:
    ##       - namespaceSelector:
    ##           matchLabels:
    ##             label: example
    ##
    customRules: {}

## @section Database Parameters
##

## MariaDB chart configuration
## ref: https://github.com/bitnami/charts/blob/main/bitnami/mariadb/values.yaml
##
mariadb:
  ## @param mariadb.enabled Deploy a MariaDB server to satisfy the applications database requirements
  ## To use an external database set this to false and configure the `externalDatabase.*` parameters
  ##
  enabled: false
  ## @param mariadb.architecture MariaDB architecture. Allowed values: `standalone` or `replication`
  ##
  architecture: standalone
  ## MariaDB Authentication parameters
  ## @param mariadb.auth.rootPassword MariaDB root password
  ## @param mariadb.auth.database MariaDB custom database
  ## @param mariadb.auth.username MariaDB custom user name
  ## @param mariadb.auth.password MariaDB custom user password
  ## ref: https://github.com/bitnami/containers/tree/main/bitnami/mariadb#setting-the-root-password-on-first-run
  ##      https://github.com/bitnami/containers/blob/main/bitnami/mariadb/README.md#creating-a-database-on-first-run
  ##      https://github.com/bitnami/containers/blob/main/bitnami/mariadb/README.md#creating-a-database-user-on-first-run
  ##
  auth:
    rootPassword: ""
    database: bitnami_wordpress
    username: bn_wordpress
    password: ""
  ## MariaDB Primary configuration
  ##
  primary:
    ## MariaDB Primary Persistence parameters
    ## ref: https://kubernetes.io/docs/user-guide/persistent-volumes/
    ## @param mariadb.primary.persistence.enabled Enable persistence on MariaDB using PVC(s)
    ## @param mariadb.primary.persistence.storageClass Persistent Volume storage class
    ## @param mariadb.primary.persistence.accessModes [array] Persistent Volume access modes
    ## @param mariadb.primary.persistence.size Persistent Volume size
    ##
    persistence:
      enabled: true
      storageClass: ""
      accessModes:
        - ReadWriteOnce
      size: 8Gi
## External Database Configuration
## All of these values are only used if `mariadb.enabled=false`
##
externalDatabase:
  ## @param externalDatabase.host External Database server host
  ##
  host: ${externalDatabaseHost}
  ## @param externalDatabase.port External Database server port
  ##
  port: ${externalDatabasePort}
  ## @param externalDatabase.user External Database username
  ##
  user: ${externalDatabaseUser}
  ## @param externalDatabase.password External Database user password
  ##
  password: ${externalDatabasePassword}
  ## @param externalDatabase.database External Database database name
  ##
  database: ${externalDatabaseDatabase}
  ## @param externalDatabase.existingSecret The name of an existing secret with database credentials. Evaluated as a template
  ## NOTE: Must contain key `mariadb-password`
  ## NOTE: When it's set, the `externalDatabase.password` parameter is ignored
  ##
  existingSecret: ${externalDatabaseExistingSecret}
## Memcached chart configuration
## ref: https://github.com/bitnami/charts/blob/main/bitnami/memcached/values.yaml
##
memcached:
  ## @param memcached.enabled Deploy a Memcached server for caching database queries
  ##
  enabled: ${memcachedEnabled}
  ## Authentication parameters
  ## ref: https://github.com/bitnami/containers/tree/main/bitnami/memcached#creating-the-memcached-admin-user
  ##
  auth:
    ## @param memcached.auth.enabled Enable Memcached authentication
    ##
    enabled: false
    ## @param memcached.auth.username Memcached admin user
    ##
    username: ""
    ## @param memcached.auth.password Memcached admin password
    ##
    password: ""
  ## Service parameters
  ##
  service:
    ## @param memcached.service.port Memcached service port
    ##
    port: 11211
## External Memcached Configuration
## All of these values are only used if `memcached.enabled=false`
##
externalCache:
  ## @param externalCache.host External cache server host
  ##
  host: ${externalCacheHost}
  ## @param externalCache.port External cache server port
  ##
  port: ${externalCachePort}
