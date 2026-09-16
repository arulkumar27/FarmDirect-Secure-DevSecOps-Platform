variable "environment" {
  type = string
}

variable "private_app_subnet_ids" {
  description = "Private subnets where ECS Fargate tasks run."
  type        = list(string)
}

variable "frontend_security_group_id" {
  description = "Security group attached only to frontend ECS tasks."
  type        = string
}

variable "backend_security_group_id" {
  description = "Security group attached only to backend ECS tasks."
  type        = string
}

variable "frontend_target_group_arn" {
  type    = string
  default = ""
}

variable "backend_target_group_arn" {
  type    = string
  default = ""
}

variable "frontend_image" {
  description = "Full frontend ECR image URI with immutable tag."
  type        = string
  default     = ""
}

variable "backend_image" {
  description = "Full backend ECR image URI with immutable tag."
  type        = string
  default     = ""
}

variable "database_host" {
  type    = string
  default = ""
}

variable "database_name" {
  type    = string
  default = "farmdirect"
}

variable "database_username" {
  type    = string
  default = "farmdirectadmin"
}

variable "database_password_secret_arn" {
  description = "Existing Secrets Manager ARN containing DB password."
  type        = string
  sensitive   = true
  default     = ""
}

variable "jwt_secret_arn" {
  description = "Existing Secrets Manager ARN containing JWT secret."
  type        = string
  sensitive   = true
  default     = ""
}

variable "application_domain" {
  type    = string
  default = "farmdirect.blacktunes.in"
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

variable "create_ecs" {
  description = "Safety switch. ECS resources create only when true."
  type        = bool
  default     = false
}