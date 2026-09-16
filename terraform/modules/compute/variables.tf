variable "environment" {
  type = string
}

variable "private_app_subnet_ids" {
  type = list(string)
}

variable "application_security_group_id" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "target_group_arn" {
  type    = string
  default = null
}

variable "instance_type" {
  type = string
}

variable "min_instances" {
  type = number
}

variable "desired_instances" {
  type = number
}

variable "max_instances" {
  type = number
}

variable "create_compute" {
  type    = bool
  default = false
}