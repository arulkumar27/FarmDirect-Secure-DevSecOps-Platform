variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_app_subnet_ids" {
  type = list(string)
}

variable "private_app_route_table_id" {
  type = string
}

variable "frontend_security_group_id" {
  type = string
}

variable "backend_security_group_id" {
  type = string
}

variable "create_vpc_endpoints" {
  type    = bool
  default = false
}

variable "enable_interface_endpoints" {
  type    = bool
  default = false
}