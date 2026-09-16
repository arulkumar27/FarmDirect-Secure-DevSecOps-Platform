variable "environment" {
  description = "Environment name used for resource tags."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the FarmDirect VPC."
  type        = string
}

variable "availability_zones" {
  description = "Two Availability Zones for high availability."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public ALB subnets."
  type        = list(string)
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for private application subnets."
  type        = list(string)
}

variable "private_database_subnet_cidrs" {
  description = "CIDR blocks for isolated database subnets."
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Creates NAT Gateway only when explicitly enabled."
  type        = bool
  default     = false
}