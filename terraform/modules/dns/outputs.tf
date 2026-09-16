output "application_domain" {
  description = "FarmDirect Route 53 application record."
  value       = try(aws_route53_record.farmdirect[0].fqdn, null)
}