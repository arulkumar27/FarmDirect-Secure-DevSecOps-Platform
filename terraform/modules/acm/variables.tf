variable "environment" {
  type = string
}

variable "route53_zone_id" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "create_acm_certificate" {
  type    = bool
  default = false
}