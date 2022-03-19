# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress#example-usage
resource "kubernetes_ingress" "app" {
  metadata {
    name      = "owncloud-lb"
    namespace = var.environment_namespace
    annotations = {
      "kubernetes.io/ingress.class"           = "alb"
      "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
    }
    labels = {
      "app" = "owncloud"
    }
  }

  spec {
    backend {
      service_name = "owncloud-service"
      service_port = 80
    }
    rule {
      http {
        path {
          path = "/"
          backend {
            service_name = "owncloud-service"
            service_port = 80
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service.app]
}


resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.environment_domain.id
  name    = var.environment_domain
  type    = "CNAME"
  records = [kubernetes_ingress.app.status.0.load_balancer.0.ingress.0.hostname]
}
