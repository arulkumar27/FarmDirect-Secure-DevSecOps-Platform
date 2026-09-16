output "certificate_arn" {
  description = "Validated ACM certificate ARN used by the ALB HTTPS listener."
  value       = try(aws_acm_certificate_validation.farmdirect[0].certificate_arn, null)
}