#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: Wordpress module outputs
#------------------------------------------------------------------------------
output "wordpressConfig" {
  value = var.wordpressConfig
}

output "tags" {
  value = var.tags
}

output "wordpress-id" {
  description = "The Wordpress helm id"
  value       = helm_release.wordpress.id
}

output "wordpress-chart" {
  description = "The Wordpress helm chart"
  value       = helm_release.wordpress.chart
}

output "wordpress-name" {
  description = "The Wordpress helm resource name"
  value       = helm_release.wordpress.name
}

output "wordpress-namespace" {
  description = "The Wordpress helm resource namespace"
  value       = helm_release.wordpress.namespace
}

output "wordpress-status" {
  description = "The Wordpress helm resource status"
  value       = helm_release.wordpress.status
}

output "wordpress-version" {
  description = "The Wordpress helm version"
  value       = helm_release.wordpress.version
}

output "aws_route53_record-wordpress-id" {
  description = "The Wordpress DNS id"
  value       = aws_route53_record.wordpress.id
}

output "aws_route53_record-wordpress-fqdn" {
  description = "The Wordpress DNS fqdn"
  value       = aws_route53_record.wordpress.fqdn
}

output "aws_route53_record-phpmyadmin-fqdn" {
  description = "The phpMyAdmin DNS fqdn"
  value       = var.phpmyadmin == "Y" ? aws_route53_record.phpmyadmin[0].fqdn : ""
}

output "aws_route53_record-wordpress-name" {
  description = "The Wordpress DNS name"
  value       = aws_route53_record.wordpress.name
}

output "aws_route53_record-wordpress-zone_id" {
  description = "The Wordpress DNS zone_id"
  value       = aws_route53_record.wordpress.zone_id
}

output "aws_route53_record-wordpress-type" {
  description = "The Wordpress DNS type"
  value       = aws_route53_record.wordpress.type
}

output "kubernetes_secret-wordpress-id" {
  description = "The Wordpress Kubernetes secret id"
  value       = kubernetes_secret.wordpress_config.id
}

output "kubernetes_secret-wordpress-metadata" {
  description = "The Wordpress Kubernetes secret metadata"
  value       = kubernetes_secret.wordpress_config.metadata
}

output "wordpress_mysql_host" {
  sensitive = true
  value     = data.kubernetes_secret.mysql_root.data.MYSQL_HOST
}

output "wordpress_mysql_port" {
  sensitive = true
  value     = data.kubernetes_secret.mysql_root.data.MYSQL_PORT
}

output "wordpress_mysql_database" {
  value = local.externalDatabaseDatabase
}

output "wordpress_mysql_username" {
  value = local.externalDatabaseUser
}

output "kubernetes_resource_quota_cpu" {
  description = "The namespace resource limit for cpu"
  value       = var.resource_quota == "Y" ? var.resource_quota_cpu : ""
}

output "kubernetes_resource_quota_memory" {
  description = "The namespace resource limit for memory"
  value       = var.resource_quota == "Y" ? var.resource_quota_memory : ""
}
