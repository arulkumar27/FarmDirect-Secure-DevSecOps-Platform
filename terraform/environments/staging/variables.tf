variable "aws_region" {
  description = "AWS region used only when Terraform is intentionally applied."
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "staging"
}

variable "vpc_cidr" {
  description = "FarmDirect VPC CIDR range."
  type        = string
  default     = "10.40.0.0/16"
}

variable "availability_zones" {
  description = "Two Availability Zones for high availability."
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  description = "Public subnets for ALB and Internet Gateway routing."
  type        = list(string)
  default     = ["10.40.1.0/24", "10.40.2.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "Private subnets for application compute."
  type        = list(string)
  default     = ["10.40.11.0/24", "10.40.12.0/24"]
}

variable "private_database_subnet_cidrs" {
  description = "Private isolated subnets for PostgreSQL."
  type        = list(string)
  default     = ["10.40.21.0/24", "10.40.22.0/24"]
}

variable "enable_nat_gateway" {
  type    = bool
  default = false
}

variable "enable_interface_endpoints" {
  type    = bool
  default = false
}

variable "create_alb" {
  type    = bool
  default = false
}

variable "create_database" {
  type    = bool
  default = false
}

variable "create_route53_record" {
  type    = bool
  default = false
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
  description = "Use AWS Secrets Manager/Jenkins credentials in a real deployment. Never commit a real password."
  type        = string
  sensitive   = true
  default     = ""
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS. Keep empty until domain/certificate is ready."
  type        = string
  default     = ""
}

variable "application_port" {
  description = "FarmDirect backend container/EC2 port."
  type        = number
  default     = 5000
}

variable "create_compute" {
  description = "Creates private EC2 Auto Scaling application servers only when true."
  type        = bool
  default     = false
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "min_instances" {
  type    = number
  default = 1
}

variable "desired_instances" {
  type    = number
  default = 1
}

variable "max_instances" {
  type    = number
  default = 2
}

variable "create_vpc_endpoints" {
  description = "Creates VPC endpoints only when explicitly enabled."
  type        = bool
  default     = false
}

variable "route53_zone_id" {
  description = "Existing Route 53 hosted-zone ID for your domain."
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "App domain, for example staging.blacktunes.in."
  type        = string
  default     = ""
}

variable "create_acm_certificate" {
  description = "Requests and validates ACM certificate only when explicitly enabled."
  type        = bool
  default     = false
}