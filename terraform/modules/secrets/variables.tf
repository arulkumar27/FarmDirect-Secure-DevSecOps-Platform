variable "environment" {
  type = string
}

variable "database_password" {
  description = "Database password supplied locally during Terraform apply. Never commit it."
  type        = string
  sensitive   = true
  default     = ""
}

variable "jwt_secret" {
  description = "JWT secret supplied locally during Terraform apply. Never commit it."
  type        = string
  sensitive   = true
  default     = ""
}

variable "create_secrets" {
  description = "Safety switch. Secrets create only when intentionally enabled."
  type        = bool
  default     = false
}