apiVersion: caching.ibm.com/v1alpha1
kind: VarnishCluster
metadata:
  name: varnishcluster
  namespace: "kube-system"
spec:
  vcl:
    configMapName: vcl-config # name of the config map that will store your VCL files. Will be created if doesn't exist.
    entrypointFileName: entrypoint.vcl # main file used by Varnish to compile the VCL code.
  backend:
    port: 80
    selector:
      app.kubernetes.io/component: controller
      app.kubernetes.io/instance: common
      app.kubernetes.io/name: ingress-nginx
  service:
    port: 80 #
