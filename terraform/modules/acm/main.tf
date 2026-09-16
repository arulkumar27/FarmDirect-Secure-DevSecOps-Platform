resource "aws_acm_certificate" "farmdirect" {
  count = var.create_acm_certificate ? 1 : 0

  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "farmdirect-${var.environment}-certificate"
    Environment = var.environment
    Project     = "FarmDirect"
  }
}

resource "aws_route53_record" "certificate_validation" {
  for_each = var.create_acm_certificate ? {
    for validation in aws_acm_certificate.farmdirect[0].domain_validation_options :
    validation.domain_name => {
      name   = validation.resource_record_name
      record = validation.resource_record_value
      type   = validation.resource_record_type
    }
  } : {}

  zone_id = var.route53_zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "farmdirect" {
  count = var.create_acm_certificate ? 1 : 0

  certificate_arn = aws_acm_certificate.farmdirect[0].arn

  validation_record_fqdns = [
    for record in aws_route53_record.certificate_validation :
    record.fqdn
  ]
}