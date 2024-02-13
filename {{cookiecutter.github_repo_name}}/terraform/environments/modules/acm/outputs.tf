

output "acm_environment_environment_region_acm_certificate_arn" {
  description = "the ARN of the environment certificate"
  value       = module.acm_environment_environment_region.acm_certificate_arn
}
