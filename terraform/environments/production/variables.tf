variable "aws_region" {
  type = string
  default = "ap-south-1"
}

variable "environment" {
  type = string
  default = "staging"
}

variable "eks_cluster_name" {
    type = string
    default = "farmdirect-staging"
}

variable "kubernetes_version" {
    type = string
    default = "1.33"
}

variable "vpc_cidr" {
    type = string
    default = "10.40.0.0/16"
}

variable "public_subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))

  default = {
    a = {
      cidr = "10.40.1.0/24"
      az   = "ap-south-1a"
    }

    b = {
      cidr = "10.40.2.0/24"
      az   = "ap-south-1b"
    }
  }
}

variable "app_subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))

  default = {
    a = {
      cidr = "10.40.11.0/24"
      az   = "ap-south-1a"
    }

    b = {
      cidr = "10.40.12.0/24"
      az   = "ap-south-1b"
    }
  }
}

variable "db_subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))

  default = {
    a = {
      cidr = "10.40.21.0/24"
      az   = "ap-south-1a"
    }

    b = {
      cidr = "10.40.22.0/24"
      az   = "ap-south-1b"
    }
  }
}

variable "node_instance_type" {
    type = string
    default = "t3.small"
}

variable "desired_nodes" {
    type = number
    default = 2
}

variable "min_nodes" {
    type = number
    default = 2
}

variable "max_nodes" {
    type = number
    default = 2
}

variable "enable_nat_gateway" {
    type = bool
    default = true
}

variable "create_database" {
    type = bool
    default = false
}

variable "create_secrets" {
    type = bool
    default = false
}

variable "create_vpc_endpoints" {
    type = bool
    default = false
}

variable "enable_interface_endpoints" {
    type = bool
    default = false
}

variable "database_name" {
    type = string
    default = "farmdirect"
}

variable "database_username" {
    type = string
    default = "farmdirectadmin"
}

variable "database_password" {
    type = string
    sensitive = true
    default = ""
}

variable "jwt_secret" {
    type = string
    sensitive = true
    default = ""
}

variable "domain_name" {
    type = string
    default = "farmdirect-staging.blacktunes.in"
}

variable "route53_zone_id" {
    type = string
    default = ""
}

variable "create_acm_certificate" {
    type = bool
    default = false
}

variable "cluster_log_types" {
    type = list(string)
    default = ["api", "audit", "authenticator"]
}

variable "allow_aws_apply" {
    type = bool
    default = false
}
