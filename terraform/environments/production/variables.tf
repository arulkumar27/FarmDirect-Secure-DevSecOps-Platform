variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "environment" {
  type    = string
  default = "production"
}

variable "vpc_cidr" {
  type    = string
  default = "10.40.0.0/16"
}

variable "availability_zones" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.40.1.0/24", "10.40.2.0/24"]
}

variable "private_app_subnet_cidrs" {
  type    = list(string)
  default = ["10.40.11.0/24", "10.40.12.0/24"]
}

variable "private_database_subnet_cidrs" {
  type    = list(string)
  default = ["10.40.21.0/24", "10.40.22.0/24"]
}

variable "route53_zone_id" {
  description = "Existing blacktunes.in Route 53 hosted-zone ID."
  type        = string
  default     = ""
}

variable "domain_name" {
  type    = string
  default = "farmdirect.blacktunes.in"
}

variable "certificate_arn" {
  description = "Keep empty when Terraform creates the ACM certificate."
  type        = string
  default     = ""
}

variable "database_name" {
  type    = string
  default = "farmdirect"
}

variable "database_username" {
  type    = string
  default = "farmdirectadmin"
}

variable "database_password" {
  description = "Never commit this value. Supply locally only at approved deployment time."
  type        = string
  sensitive   = true
  default     = ""
}

variable "jwt_secret" {
  description = "Never commit this value. Supply locally only at approved deployment time."
  type        = string
  sensitive   = true
  default     = ""
}

variable "frontend_image_tag" {
  type    = string
  default = "bootstrap"
}

variable "backend_image_tag" {
  type    = string
  default = "bootstrap"
}

variable "enable_nat_gateway" {
  type    = bool
  default = false
}

variable "create_secrets" {
  type    = bool
  default = false
}

variable "create_database" {
  type    = bool
  default = false
}

variable "create_acm_certificate" {
  type    = bool
  default = false
}

variable "create_alb" {
  type    = bool
  default = false
}

variable "create_route53_record" {
  type    = bool
  default = false
}

variable "create_ecs" {
  type    = bool
  default = false
}

variable "database_deletion_protection" {
  type    = bool
  default = false
}

variable "database_skip_final_snapshot" {
  type    = bool
  default = true
}

variable "alb_deletion_protection" {
  type    = bool
  default = false
}

variable "frontend_desired_count" {
  type    = number
  default = 2
}

variable "backend_desired_count" {
  type    = number
  default = 2
}

variable "backend_min_count" {
  type    = number
  default = 2
}

variable "backend_max_count" {
  type    = number
  default = 4
}

variable "create_vpc_endpoints" {
  type    = bool
  default = false
}

variable "enable_interface_endpoints" {
  type    = bool
  default = false
}

variable "allow_aws_apply" {
  description = "Hard safety lock. Keep false until the controlled AWS demo is intentionally approved."
  type        = bool
  default     = false
}