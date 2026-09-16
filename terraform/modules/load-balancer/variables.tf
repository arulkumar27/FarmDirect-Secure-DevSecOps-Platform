variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "alb_security_group_id" {
  type = string
}

variable "certificate_arn" {
  type    = string
  default = ""
}

variable "alb_access_logs_bucket_name" {
  description = "Private encrypted S3 bucket used for ALB access logs."
  type        = string
  default     = ""
}

variable "create_alb" {
  type    = bool
  default = false
}

variable "enable_deletion_protection" {
  description = "Keep false for the short controlled demo so cleanup can succeed."
  type        = bool
  default     = false
}