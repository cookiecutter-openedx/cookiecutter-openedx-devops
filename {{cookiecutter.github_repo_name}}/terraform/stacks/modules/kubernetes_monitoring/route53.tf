

data "aws_route53_zone" "environment_domain" {
  name = var.environment_domain
  tags = {
    SharedResourceNamespace = var.shared_resource_namespace
  }
}
