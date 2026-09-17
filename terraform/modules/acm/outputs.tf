output "certificate_arn" {
  value = var.create_certificate && var.zone_id != "" ? aws_acm_certificate_validation.this[0].certificate_arn : null
}