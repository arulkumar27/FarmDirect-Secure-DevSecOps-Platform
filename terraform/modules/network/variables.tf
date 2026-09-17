variable "name" {
    type=string
}

variable "vpc_cidr" {
    type=string
}

variable "eks_cluster_name" {
    type=string
}

variable "public_subnets" {
    type=map(object({cidr=string,az=string}))
}

variable "app_subnets" {
    type=map(object({cidr=string,az=string}))
}

variable "db_subnets" {
    type=map(object({cidr=string,az=string}))
}

variable "enable_nat_gateway" {
    type=bool
    default=false
}

variable "tags" {
    type=map(string)
    default={}
}
