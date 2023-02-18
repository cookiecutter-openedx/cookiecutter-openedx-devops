#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: installs Kubernetes Dashboard web application
# see: https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
#      https://blog.heptio.com/on-securing-the-kubernetes-dashboard-16b09b1b7aca
#
# to run:
#   in a separate terminal window run:  kubectl proxy
#   in a browser window run: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
#
#   The login page will ask for a token. To generate said token, run:
#   kubectl -n kubernetes-dashboard create token kubernetes-dashboard
#
#-----------------------------------------------------------

data "template_file" "_01" {
  template = file("${path.module}/yml/01_Namespace.yaml")
}

data "template_file" "_02" {
  template = file("${path.module}/yml/02_ServiceAccount.yaml")
}

data "template_file" "_03" {
  template = file("${path.module}/yml/03_Service.yaml")
}

data "template_file" "_04" {
  template = file("${path.module}/yml/04_Secret.yaml")
}

data "template_file" "_05" {
  template = file("${path.module}/yml/05_Secret.yaml")
}

data "template_file" "_06" {
  template = file("${path.module}/yml/06_Secret.yaml")
}

data "template_file" "_07" {
  template = file("${path.module}/yml/07_ConfigMap.yaml")
}

data "template_file" "_08" {
  template = file("${path.module}/yml/08_Role.yaml")
}

data "template_file" "_09" {
  template = file("${path.module}/yml/09_ClusterRole.yaml")
}

data "template_file" "_10" {
  template = file("${path.module}/yml/10_RoleBinding.yaml")
}

data "template_file" "_11" {
  template = file("${path.module}/yml/11_ClusterRoleBinding.yaml")
}

data "template_file" "_12" {
  template = file("${path.module}/yml/12_Deployment.yaml")
}

data "template_file" "_13" {
  template = file("${path.module}/yml/13_Service.yaml")
}

data "template_file" "_14" {
  template = file("${path.module}/yml/14_Deployment.yaml")
}

data "template_file" "_15" {
  template = file("${path.module}/yml/15_APIToken.yaml")
}

resource "kubectl_manifest" "_01" {
  yaml_body = data.template_file._01.rendered
}

resource "kubectl_manifest" "_02" {
  yaml_body = data.template_file._02.rendered

  depends_on = [
    kubectl_manifest._01
  ]
}
resource "kubectl_manifest" "_03" {
  yaml_body = data.template_file._03.rendered

  depends_on = [
    kubectl_manifest._02
  ]
}
resource "kubectl_manifest" "_04" {
  yaml_body = data.template_file._04.rendered

  depends_on = [
    kubectl_manifest._03
  ]
}
resource "kubectl_manifest" "_05" {
  yaml_body = data.template_file._05.rendered

  depends_on = [
    kubectl_manifest._04
  ]
}
resource "kubectl_manifest" "_06" {
  yaml_body = data.template_file._06.rendered

  depends_on = [
    kubectl_manifest._05
  ]
}
resource "kubectl_manifest" "_07" {
  yaml_body = data.template_file._07.rendered

  depends_on = [
    kubectl_manifest._06
  ]
}
resource "kubectl_manifest" "_08" {
  yaml_body = data.template_file._08.rendered

  depends_on = [
    kubectl_manifest._07
  ]
}
resource "kubectl_manifest" "_09" {
  yaml_body = data.template_file._09.rendered

  depends_on = [
    kubectl_manifest._08
  ]
}
resource "kubectl_manifest" "_10" {
  yaml_body = data.template_file._10.rendered

  depends_on = [
    kubectl_manifest._09
  ]
}
resource "kubectl_manifest" "_11" {
  yaml_body = data.template_file._11.rendered

  depends_on = [
    kubectl_manifest._10
  ]
}
resource "kubectl_manifest" "_12" {
  yaml_body = data.template_file._12.rendered

  depends_on = [
    kubectl_manifest._11
  ]
}
resource "kubectl_manifest" "_13" {
  yaml_body = data.template_file._13.rendered

  depends_on = [
    kubectl_manifest._12
  ]
}
resource "kubectl_manifest" "_14" {
  yaml_body = data.template_file._14.rendered

  depends_on = [
    kubectl_manifest._13
  ]
}
