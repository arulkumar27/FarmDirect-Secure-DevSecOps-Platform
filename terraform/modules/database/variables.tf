variable "environment" {
  type = string
}

variable "private_database_subnet_ids" {
  type = list(string)
}

variable "database_security_group_id" {
  type = string
}

variable "database_name" {
  type = string
}

variable "database_username" {
  type = string
}

variable "database_password" {
  type      = string
  sensitive = true
}

variable "create_database" {
  type    = bool
  default = false
}

variable "deletion_protection" {
  description = "Keep false for the controlled short AWS demo."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Keep true for the controlled short AWS demo."
  type        = bool
  default     = true
}